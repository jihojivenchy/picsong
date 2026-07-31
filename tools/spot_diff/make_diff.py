"""베이스 이미지 1장에서 틀린그림찾기 B컷을 만든다.

차이는 생성이 아니라 편집으로 만든다 — 디퓨전은 같은 시드라도 프롬프트가
바뀌면 그림 전체가 달라져서, 지정한 곳만 다른 두 장을 만들 수 없다.

편집 흔적이 남지 않는 세 연산만 쓴다:
  flip   — 배경이 가로 띠 구조라 좌우 반전은 이음매가 생기지 않는다
  recolor— 색상 마스크로 대상 픽셀만 색을 돌린다(사각형 경계가 안 보인다)
  erase  — 깨끗한 세로 한 줄을 복제해 배경을 재구성한다
"""

import colorsys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

BASE = Path(__file__).parent / "out" / "base_A_레코드샵.png"
OUT_DIR = Path(__file__).parent / "out"

Box = tuple[int, int, int, int]


def flip(img: Image.Image, box: Box) -> None:
    img.paste(img.crop(box).transpose(Image.FLIP_LEFT_RIGHT), box)


def recolor(img: Image.Image, box: Box, seed: tuple[int, int], hue_delta: float,
            tol: int = 90) -> None:
    region = np.array(img.crop(box), dtype=np.int16)
    target = np.array(img.getpixel(seed), dtype=np.int16)
    mask = np.linalg.norm(region - target, axis=2) < tol
    ys, xs = np.nonzero(mask)
    for y, x in zip(ys, xs):
        r, g, b = region[y, x] / 255
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        region[y, x] = [round(c * 255) for c in colorsys.hsv_to_rgb((h + hue_delta) % 1, s, v)]
    img.paste(Image.fromarray(region.astype(np.uint8)), box)


def erase(img: Image.Image, box: Box, src_x: int) -> None:
    left, top, right, bottom = box
    strip = img.crop((src_x, top, src_x + 1, bottom))
    img.paste(strip.resize((right - left, bottom - top), Image.NEAREST), box)


# (설명, 박스, 적용 함수)
DIFFS: list[tuple[str, Box, object]] = [
    ("액자 속 고양이 좌우 반전", (402, 156, 499, 243), lambda im, b: flip(im, b)),
    ("선반 위 화분 색 변경", (430, 40, 490, 105), lambda im, b: recolor(im, b, (456, 72), 0.75)),
    ("흰 고양이 삭제", (315, 440, 371, 512), lambda im, b: erase(im, b, 390)),
    ("기타 몸통 색 변경", (88, 350, 182, 500), lambda im, b: recolor(im, b, (130, 430), 0.55)),
]


def main() -> None:
    a = Image.open(BASE).convert("RGB")
    b = a.copy()
    for _, box, apply in DIFFS:
        apply(b, box)
    a.save(OUT_DIR / "quiz_A.png")
    b.save(OUT_DIR / "quiz_B.png")
    key = b.copy()
    draw = ImageDraw.Draw(key)
    for i, (label, box, _) in enumerate(DIFFS, start=1):
        draw.rectangle(box, outline=(255, 0, 0), width=3)
        draw.text((box[0] + 5, box[1] + 5), str(i), fill=(255, 0, 0))
        print(f"  {i}. {label}  {box}")
    key.save(OUT_DIR / "quiz_KEY.png")
    print(f"\n완료 → {OUT_DIR}")


if __name__ == "__main__":
    main()
