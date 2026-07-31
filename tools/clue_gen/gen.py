"""songs.json의 imagePrompt로 클루 이미지를 생성한다.

venv·모델 캐시는 프로젝트 밖(~/.cache/picsong_clue_gen)에 둔다.

사용법:
    python gen.py song_001              # 특정 곡의 전 라인
    python gen.py --all --model sdxl    # 25곡 85줄 전부
    python gen.py --variants v.json     # 프롬프트 후보 비교 (songs.json 무관)
"""

import argparse
import json
import time
from pathlib import Path

import torch
from diffusers import AutoPipelineForText2Image

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SONGS_JSON = PROJECT_ROOT / "assets" / "data" / "songs.json"
OUT_ROOT = Path(__file__).parent / "out"

# 모델별 권장 설정. turbo 계열은 저스텝·CFG 0, 기본 계열은 고스텝·CFG 사용.
MODELS = {
    "turbo": {
        "id": "stabilityai/sd-turbo",
        "steps": 4,
        "guidance": 0.0,
        "size": 512,
    },
    "sdxl": {
        "id": "stabilityai/stable-diffusion-xl-base-1.0",
        "steps": 30,
        "guidance": 7.0,
        "size": 1024,
    },
}

# 화풍 프리셋. CLIP 한계가 77토큰이므로 가사 프롬프트가 잘리지 않게 짧게 유지한다.
STYLES = {
    "none": "",
    "matte": (
        "muted gouache painting, flat plain background, desaturated palette, "
        "soft even light, Korean, black hair"
    ),
    "anime": (
        "anime illustration, cel shaded, clean bold lineart, vibrant colors, "
        "Korean characters"
    ),
    "line": (
        "minimal black ink line drawing, single continuous line, white background, "
        "no shading, no color, simple pictogram"
    ),
    "sketch": (
        "simple black pen sketch on white paper, loose hand-drawn outlines, "
        "no shading, no color"
    ),
}


def load_from_songs(song_ids: list[str] | None) -> list[dict]:
    songs = json.loads(SONGS_JSON.read_text(encoding="utf-8"))
    if song_ids:
        songs = [s for s in songs if s["id"] in song_ids]
    return [
        {
            "label": f"{s['id']}_{i}",
            "prompt": line["imagePrompt"],
            "note": f"{s['title']} — {line['text']}",
        }
        for s in songs
        for i, line in enumerate(s["lyricLines"])
    ]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("song_ids", nargs="*")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--variants", type=Path)
    parser.add_argument("--model", choices=list(MODELS), default="sdxl")
    parser.add_argument("--style", choices=list(STYLES), default="matte")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--steps", type=int)
    parser.add_argument("--size", type=int)
    args = parser.parse_args()

    targets = (
        json.loads(args.variants.read_text(encoding="utf-8"))
        if args.variants
        else load_from_songs(None if args.all else args.song_ids)
    )
    if not targets:
        raise SystemExit("대상 없음 — song_id 또는 --variants를 확인하세요")

    cfg = MODELS[args.model]
    steps = args.steps or cfg["steps"]
    size = args.size or cfg["size"]
    style = STYLES[args.style]
    out_dir = OUT_ROOT / f"{args.model}_{args.style}"
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"모델 로딩: {cfg['id']}")
    pipe = AutoPipelineForText2Image.from_pretrained(
        cfg["id"], torch_dtype=torch.float16, variant="fp16"
    ).to("mps")

    print(f"\n{len(targets)}장 생성 ({steps} steps, {size}px)\n")
    for t in targets:
        started = time.time()
        image = pipe(
            prompt=f"{style}, {t['prompt']}" if style else t["prompt"],
            num_inference_steps=steps,
            guidance_scale=cfg["guidance"],
            height=size,
            width=size,
            generator=torch.Generator("mps").manual_seed(args.seed),
        ).images[0]
        image.save(out_dir / f"{t['label']}.png")
        print(f"  {t['label']}  {time.time() - started:5.1f}s  {t.get('note', '')}")

    print(f"\n완료 → {out_dir}")


if __name__ == "__main__":
    main()
