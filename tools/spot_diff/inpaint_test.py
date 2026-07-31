"""인페인팅으로 틀린 곳을 만들 수 있는지 검증한다.

마스크 밖은 원본 픽셀이 보존되므로 원리상 틀린그림찾기에 맞다.
검증 대상은 두 가지 — 마스크 밖이 정말 무손상인가, 마스크 안 품질이 쓸만한가.
"""

from pathlib import Path

import numpy as np
import torch
from diffusers import AutoPipelineForInpainting
from PIL import Image, ImageDraw, ImageFilter

BASE = Path(__file__).parent / "out" / "base_A_레코드샵.png"
OUT_DIR = Path(__file__).parent / "out"

STYLE = "flat vector illustration, bold clean outlines, flat solid colors"

# (라벨, 마스크 박스, 그 자리에 새로 그릴 것)
EDITS = [
    ("고양이삭제", (308, 435, 380, 512), "empty wooden floor and plain blue wall, nothing"),
    ("액자교체", (405, 158, 496, 240), "a framed picture of a red bird on dark navy background"),
    ("화분교체", (428, 20, 492, 100), "a stack of books on a shelf"),
]


def make_mask(box: tuple[int, int, int, int]) -> Image.Image:
    mask = Image.new("L", (512, 512), 0)
    ImageDraw.Draw(mask).rectangle(box, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(4))


def main() -> None:
    pipe = AutoPipelineForInpainting.from_pretrained(
        "stabilityai/sd-turbo", torch_dtype=torch.float16, variant="fp16"
    ).to("mps")
    base = Image.open(BASE).convert("RGB")
    for label, box, prompt in EDITS:
        result = pipe(
            prompt=f"{STYLE}, {prompt}",
            image=base,
            mask_image=make_mask(box),
            num_inference_steps=4,
            guidance_scale=0.0,
            strength=1.0,
            height=512,
            width=512,
            generator=torch.Generator("mps").manual_seed(7),
        ).images[0]
        result.save(OUT_DIR / f"inpaint_{label}.png")
        # VAE 디코드가 전체를 다시 그리므로, 마스크 밖은 원본을 픽셀로 되붙인다
        composited = Image.composite(result, base, make_mask(box))
        composited.save(OUT_DIR / f"inpaint_{label}_합성.png")
        for name, img in (("합성전", result), ("합성후", composited)):
            diff = np.abs(np.array(img, dtype=np.int16) - np.array(base, dtype=np.int16)).sum(axis=2)
            diff[box[1]:box[3], box[0]:box[2]] = 0
            print(f"  {label:8s} {name} 마스크밖 최대차={diff.max():3d} 변경픽셀={int((diff > 8).sum()):6d}")


if __name__ == "__main__":
    main()
