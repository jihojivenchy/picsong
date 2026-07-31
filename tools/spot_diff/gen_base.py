"""틀린그림찾기 베이스 이미지 후보를 생성한다.

차이(틀린 곳)는 생성하지 않는다 — make_diff.py가 편집으로 만든다.
"""

import time
from pathlib import Path

import torch
from diffusers import AutoPipelineForText2Image

OUT_DIR = Path(__file__).parent / "out"

# 틀린그림찾기용 화풍. 평면적일수록 편집으로 차이를 만들기 쉽다.
STYLE = (
    "flat vector illustration, bold clean outlines, flat solid colors, "
    "no gradients, no texture, children's picture book"
)

# 오브젝트가 많고 서로 떨어져 있는 장면일수록 게임이 성립한다.
CANDIDATES = [
    {
        "label": "A_레코드샵",
        "prompt": (
            "a cozy record shop interior, shelves of vinyl records, "
            "a guitar on the wall, a potted plant, a wall clock, a cat on the counter"
        ),
    },
    {
        "label": "B_음악방",
        "prompt": (
            "a teenager's bedroom with a desk, headphones, a guitar in the corner, "
            "posters on the wall, a lamp, a bookshelf, a small round rug"
        ),
    },
    {
        "label": "C_거리",
        "prompt": (
            "a small town street with shop fronts, a bakery, a bicycle parked, "
            "a street lamp, a bench, a tree, birds in the sky"
        ),
    },
]


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    pipe = AutoPipelineForText2Image.from_pretrained(
        "stabilityai/sd-turbo", torch_dtype=torch.float16, variant="fp16"
    ).to("mps")
    for i, c in enumerate(CANDIDATES):
        started = time.time()
        image = pipe(
            prompt=f"{STYLE}, {c['prompt']}",
            num_inference_steps=4,
            guidance_scale=0.0,
            height=512,
            width=512,
            generator=torch.Generator("mps").manual_seed(100 + i),
        ).images[0]
        image.save(OUT_DIR / f"base_{c['label']}.png")
        print(f"  {c['label']}  {time.time() - started:5.1f}s")


if __name__ == "__main__":
    main()
