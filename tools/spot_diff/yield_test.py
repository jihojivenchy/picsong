"""틀린그림찾기 베이스로 쓸 수 있는 그림이 몇 퍼센트 나오는지 측정한다.

온디바이스에서는 사람이 고를 수 없으므로, 뽑은 것을 그대로 퍼즐로 낼 수 있어야 한다.
장면 4종 × 시드 4개를 뽑아 한 장의 대조표로 만든다.
"""

import time
from pathlib import Path

import torch
from diffusers import AutoPipelineForText2Image
from PIL import Image, ImageDraw

OUT_DIR = Path(__file__).parent / "out"
THUMB = 256

STYLE = (
    "flat vector illustration, bold clean outlines, flat solid colors, "
    "no gradients, no texture, children's picture book"
)

# 사람은 넣지 않는다 — sd-turbo가 얼굴·인체를 제대로 못 그린다는 건 모델 카드 명시 한계다.
SCENES = [
    ("선반", "a wall of shelves with books, potted plants, a clock, boxes and jars"),
    ("책상", "a desk seen from above with stationery, a mug, notebooks, a lamp, scattered pens"),
    ("거리", "a row of small shop fronts with awnings, a bicycle, a street lamp, a bench, a tree"),
    ("주방", "a kitchen counter with pots, fruit in a bowl, bottles, a kettle, hanging utensils"),
]
SEEDS = [11, 22, 33, 44]


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    pipe = AutoPipelineForText2Image.from_pretrained(
        "stabilityai/sd-turbo", torch_dtype=torch.float16, variant="fp16"
    ).to("mps")
    sheet = Image.new("RGB", (THUMB * len(SEEDS), THUMB * len(SCENES)), (255, 255, 255))
    draw = ImageDraw.Draw(sheet)
    started = time.time()
    for row, (name, prompt) in enumerate(SCENES):
        for col, seed in enumerate(SEEDS):
            image = pipe(
                prompt=f"{STYLE}, {prompt}",
                num_inference_steps=4,
                guidance_scale=0.0,
                height=512,
                width=512,
                generator=torch.Generator("mps").manual_seed(seed),
            ).images[0]
            image.save(OUT_DIR / f"yield_{name}_{seed}.png")
            sheet.paste(image.resize((THUMB, THUMB), Image.LANCZOS), (col * THUMB, row * THUMB))
            draw.text((col * THUMB + 6, row * THUMB + 6), f"{name}-{seed}", fill=(255, 0, 0))
    sheet.save(OUT_DIR / "yield_sheet.png")
    total = len(SCENES) * len(SEEDS)
    print(f"{total}장 / {time.time() - started:.0f}초 → {OUT_DIR / 'yield_sheet.png'}")


if __name__ == "__main__":
    main()
