#!/usr/bin/env python3
import os
import shutil
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math
import sys
from concurrent.futures import ProcessPoolExecutor, as_completed
import multiprocessing

# Configuration
WIDTH = HEIGHT = int(os.getenv("BOOTANIM_SIZE", "1440"))
SCALE = WIDTH / 1440.0
FPS = 60

# Part 0: Slide-in (plays once)
DURATION_SLIDE = 0.7
FRAMES_SLIDE = int(FPS * DURATION_SLIDE)

# Part 1: Loop (repeats)
DURATION_LOOP = 3.0
FRAMES_LOOP = int(FPS * DURATION_LOOP)

# Part 2: Fade-out (plays once when shutting down)
DURATION_FADEOUT = 1.5
FRAMES_FADEOUT = int(FPS * DURATION_FADEOUT)

OFFSET = -WIDTH // 2  # Start halfway outside the screen

# Colors - halogenOS brand
BLUE_START = (0, 180, 231)  # #00B4E7 - lighter
BLUE_END = (0, 120, 180)    # Darker blue for gradient
WHITE_START = (200, 230, 255)  # Light blue-white
WHITE_END = (150, 200, 230)    # Slightly darker for gradient
BACKGROUND = (0, 0, 0)
GLOW_COLOR = (0, 180, 255)  # Brighter blue glow

def interpolate_color(color1, color2, t):
    """Interpolate between two colors"""
    return tuple(int(c1 + (c2 - c1) * t) for c1, c2 in zip(color1, color2))

def create_rounded_triangle_mask(size, points, radius):
    """Create a mask for a triangle with rounded corners"""
    mask = Image.new('L', size, 0)
    temp_mask = Image.new('L', size, 0)
    draw = ImageDraw.Draw(temp_mask)
    draw.polygon(points, fill=255)
    temp_mask = temp_mask.filter(ImageFilter.GaussianBlur(radius=radius))
    mask = Image.eval(temp_mask, lambda x: 255 if x > 128 else 0)
    return mask

def draw_triangle_with_gradient(img, points, color_start, color_end, opacity=255, corner_radius=30):
    """Draw a triangle with diagonal gradient and rounded corners"""
    mask = create_rounded_triangle_mask((WIDTH, HEIGHT), points, corner_radius*SCALE)
    gradient = Image.new('RGBA', (WIDTH, HEIGHT))
    gradient_draw = ImageDraw.Draw(gradient)

    x_coords = [p[0] for p in points]
    y_coords = [p[1] for p in points]
    x_min, x_max = min(x_coords), max(x_coords)
    y_min, y_max = min(y_coords), max(y_coords)

    for y in range(int(y_min), int(y_max) + 1):
        for x in range(int(x_min), int(x_max) + 1):
            if x_max > x_min and y_max > y_min:
                t = ((x - x_min) / (x_max - x_min) + (y - y_min) / (y_max - y_min)) / 2
            else:
                t = 0
            color = interpolate_color(color_start, color_end, t)
            gradient_draw.point((x, y), fill=(*color, opacity))

    gradient.putalpha(mask)
    img.alpha_composite(gradient)

def add_glow(img, intensity=0.5, radius=40, color=GLOW_COLOR):
    """Add colored glow effect around the entire logo"""
    if intensity <= 0:
        return img

    result = Image.new('RGBA', (WIDTH, HEIGHT), (0, 0, 0, 0))

    for i in range(3):
        glow_layer = Image.new('RGBA', (WIDTH, HEIGHT), (*color, 0))
        _, _, _, alpha = img.split()
        glow_layer.putalpha(alpha)

        blur_radius = int(radius * (1 + i * 0.6))
        glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=blur_radius))

        if i > 0:
            _, _, _, glow_alpha = glow_layer.split()
            glow_alpha = glow_alpha.point(lambda x: int(x * (1 - i * 0.25)))
            glow_layer.putalpha(glow_alpha)

        result = Image.alpha_composite(result, glow_layer)

    _, _, _, result_alpha = result.split()
    result_alpha = result_alpha.point(lambda x: int(x * intensity))
    result.putalpha(result_alpha)

    final = Image.alpha_composite(result, img)
    black_bg = Image.new('RGBA', (WIDTH, HEIGHT), (*BACKGROUND, 255))
    return Image.alpha_composite(black_bg, final)

def scale_points(points, scale, center):
    """Scale points around a center"""
    cx, cy = center
    scaled = []
    for x, y in points:
        dx = x - cx
        dy = y - cy
        scaled.append((cx + dx * scale, cy + dy * scale))
    return scaled

def generate_frame(part, frame_num, total_frames):
    """Generate a single frame based on part and frame number"""
    img = Image.new('RGBA', (WIDTH, HEIGHT), (0, 0, 0, 0))
    cx, cy = WIDTH // 2, HEIGHT // 2
    triangle_size = 350 * SCALE

    # Calculate animation state based on part
    if part == 0:  # Slide-in
        t = frame_num / total_frames
        # Strong ease-out curve
        t = 1 - math.pow(1 - t, 4)
        offset = OFFSET * (1 - t)

        # Fade in
        opacity = min(1.0, frame_num / (total_frames * 0.5))

        # Scale animation that ends at the starting scale of the breathing animation
        # End at scale 1.03 to match the midpoint of the breathing cycle
        scale = 0.8 + 0.23 * t

        # Glow that ends at the midpoint intensity of the breathing cycle
        glow_intensity = 0.33 * t

    elif part == 1:  # Loop
        t = frame_num / total_frames
        offset = 0
        opacity = 1.0

        # Breathing animation that starts and ends at the same scale
        # This ensures smooth looping and smooth transition from part0
        scale = 1.03 + 0.03 * math.sin(t * 2 * math.pi)

        # Pulsing glow that starts and ends at the same intensity
        glow_intensity = 0.33 + 0.1 * math.sin(t * 2 * math.pi)

    else:  # part == 2, Fade-out
        t = frame_num / total_frames

        # Start with a brief hold, then accelerate the fade
        if t < 0.1:  # Hold for first 10% of fade-out
            fade_t = 0
        else:
            fade_t = (t - 0.1) / 0.9  # Normalize remaining 90%
            fade_t = math.pow(fade_t, 0.7)  # Accelerating fade

        offset = 0
        opacity = 1.0 - fade_t

        # Start from the midpoint scale of the breathing animation
        # This ensures smooth transition regardless of where part1 was interrupted
        scale = 1.03 - 0.23 * fade_t
        glow_intensity = 0.33 * (1 - fade_t)

    # Calculate triangle points with adjusted overlap
    overlap_amount = triangle_size * 0.10

    # Blue triangle (pointing left) - slightly right of center
    blue_center_x = cx + overlap_amount // 2
    blue_points = [
        (blue_center_x - triangle_size - offset, cy),
        (blue_center_x + triangle_size // 2 - offset, cy - triangle_size * 0.8),
        (blue_center_x + triangle_size // 2 - offset, cy + triangle_size * 0.8),
    ]

    # White triangle (pointing right) - slightly left of center
    white_center_x = cx - overlap_amount // 2
    white_points = [
        (white_center_x + triangle_size + offset, cy),
        (white_center_x - triangle_size // 2 + offset, cy - triangle_size * 0.8),
        (white_center_x - triangle_size // 2 + offset, cy + triangle_size * 0.8),
    ]

    # Apply scale if needed
    if scale != 1.0:
        blue_points = scale_points(blue_points, scale, (cx, cy))
        white_points = scale_points(white_points, scale, (cx, cy))

    # Draw blue triangle (back layer, full opacity)
    draw_triangle_with_gradient(img, blue_points, BLUE_START, BLUE_END, int(255 * opacity))

    # Draw white triangle (front layer, more transparent)
    white_opacity = int(140 * opacity)
    draw_triangle_with_gradient(img, white_points, WHITE_START, WHITE_END, white_opacity)

    # Apply glow effect and composite onto black background
    return add_glow(img, glow_intensity, radius=60*SCALE)

def generate_frame_wrapper(args):
    """Wrapper for multiprocessing"""
    part, frame_num, total_frames, output_path = args
    frame = generate_frame(part, frame_num, total_frames)
    frame.save(output_path, 'PNG')
    return frame_num

def generate_part_frames(part_num, part_dir, frame_count, part_name):
    """Generate frames for a single part using multiprocessing"""
    print(f"\nGenerating Part {part_num} ({part_name}): {frame_count} frames")

    tasks = []
    for i in range(frame_count):
        filename = f'{part_dir}/frame_{i:04d}.png'
        tasks.append((part_num, i, frame_count, filename))

    num_workers = multiprocessing.cpu_count()
    completed = 0

    with ProcessPoolExecutor(max_workers=num_workers) as executor:
        futures = {executor.submit(generate_frame_wrapper, task): task for task in tasks}

        for future in as_completed(futures):
            completed += 1
            if completed % 10 == 0:
                print(f"  Frame {completed}/{frame_count}")

def main():
    """Generate all frames for all parts"""
    base_dir = os.getenv("OUTPUT_DIR", 'bootanimation_frames')

    if os.path.exists("frameworks") and base_dir == "bootanimation_frames":
        print("Refusing to run in source root")
        sys.exit(1)

    if os.path.exists(base_dir):
        print(f"Removing old frames in '{base_dir}'...")
        shutil.rmtree(base_dir)

    os.makedirs(base_dir)

    print(f"Using {multiprocessing.cpu_count()} CPU cores for parallel processing")

    # Generate Part 0: Slide-in
    part0_dir = os.path.join(base_dir, 'part0')
    os.makedirs(part0_dir)
    generate_part_frames(0, part0_dir, FRAMES_SLIDE, "slide-in")

    # Generate Part 1: Loop
    part1_dir = os.path.join(base_dir, 'part1')
    os.makedirs(part1_dir)
    generate_part_frames(1, part1_dir, FRAMES_LOOP, "loop")

    # Generate Part 2: Fade-out
    part2_dir = os.path.join(base_dir, 'part2')
    os.makedirs(part2_dir)
    generate_part_frames(2, part2_dir, FRAMES_FADEOUT, "fade-out")

    # Generate desc.txt
    desc_content = f"""{WIDTH} {HEIGHT} {FPS}
p 1 0 part0
p 0 0 part1
c 1 0 part2
"""

    desc_path = os.path.join(base_dir, 'desc.txt')
    with open(desc_path, 'w') as f:
        f.write(desc_content)

if __name__ == "__main__":
    main()