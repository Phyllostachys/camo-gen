package camogen

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

width :: 800
height :: 600
tex_width :: 300
tex_height :: 225
tex_scale :: math.min(cast(f32)width / cast(f32)tex_width, cast(f32)height / cast(f32)tex_height)

MY_GREEN :: rl.Color{107, 142, 35, 255}
MY_BROWN :: rl.Color{135, 74, 43, 255}

PixelType :: enum {
	Black,
	Green,
	Brown
}

pixeltype_to_color :: proc(pt: PixelType) -> rl.Color {
	ret: rl.Color

	switch pt {
	case .Black:
		ret = rl.BLACK
	case .Green:
		ret = MY_GREEN
	case .Brown:
		ret = MY_BROWN
	}

	return ret
}

App :: struct {
	screen_image: rl.Image,
	screen_tex: rl.Texture2D,
	running: bool
}

// randomize image data
app_randomize :: proc(app: ^App) {
	for y in 0..<app.screen_image.height {
		for x in 0..<app.screen_image.width {
			new_color := pixeltype_to_color(rand.choice_enum(PixelType))
			rl.ImageDrawPixel(&app.screen_image, x, y, new_color)
		}
	}
}

SurroundCount :: struct {
	black: int,
	green: int,
	brown: int
}

get_surround_counts :: proc(image: rl.Image, x, y: int) -> SurroundCount {
	return SurroundCount {
		search_for_similar(image, x, y, rl.BLACK),
		search_for_similar(image, x, y, MY_GREEN),
		search_for_similar(image, x, y, MY_BROWN),
	}
}

search_for_similar :: proc(image: rl.Image, x, y: int, color: rl.Color) -> int {
	result: int

	width := cast(int)image.width
	height := cast(int)image.height
	left := (x - 1) % width
	right := (x + 1) % width
	top := (y - 1) % height
	bottom := (y + 1) % height

	if x == 0 {
		left = width - 1
	}
	if x == width {
		right = 0
	}
	if y == 0 {
		top = height - 1
	}
	if y == height {
		bottom = 0
	}

	// top
	if rl.GetImageColor(image, cast(i32)left, cast(i32)top) == color {
		result += 1
	}
	if rl.GetImageColor(image, cast(i32)x, cast(i32)top) == color {
		result += 1
	}
	if rl.GetImageColor(image, cast(i32)right, cast(i32)top) == color {
		result += 1
	}

	// left and right
	if rl.GetImageColor(image, cast(i32)left, cast(i32)y) == color {
		result += 1
	}
	if rl.GetImageColor(image, cast(i32)right, cast(i32)y) == color {
			result += 1
	}

	// bottom
	if rl.GetImageColor(image, cast(i32)left, cast(i32)bottom) == color {
		result += 1
	}
	if rl.GetImageColor(image, cast(i32)x, cast(i32)bottom) == color {
		result += 1
	}
	if rl.GetImageColor(image, cast(i32)right, cast(i32)bottom) == color {
		result += 1
	}

	return result
}

sample_fanbase :: proc(image: rl.Image, x, y: int) -> rl.Color {
	new_color: rl.Color
	surroundings := get_surround_counts(image, x, y)

	switch rl.GetImageColor(image, cast(i32)x, cast(i32)y) {
	case rl.BLACK:
		if surroundings.black >= 4 {
			new_color = rl.BLACK
		} else if surroundings.green == surroundings.brown {
			// random
			new_color = pixeltype_to_color(rand.choice_enum(PixelType))
		} else if surroundings.green > surroundings.brown {
			new_color = MY_GREEN
		} else {
			new_color = MY_BROWN
		}
	case MY_GREEN:
		if surroundings.green >= 4 {
			new_color = MY_GREEN
		} else if surroundings.black == surroundings.brown {
			// random
			new_color = pixeltype_to_color(rand.choice_enum(PixelType))
		} else if surroundings.black > surroundings.brown {
			new_color = rl.BLACK
		} else {
			new_color = MY_BROWN
		}
	case MY_BROWN:
		if surroundings.brown >= 4 {
			new_color = MY_BROWN
		} else if surroundings.green == surroundings.black {
			// random
			new_color = pixeltype_to_color(rand.choice_enum(PixelType))
		} else if surroundings.green > surroundings.black {
			new_color = MY_GREEN
		} else {
			new_color = rl.BLACK
		}
	}

	return new_color
}

update :: proc(app: ^App) {
	if rl.IsKeyPressed(.S) {
		app.running = !app.running
	}

	if rl.IsKeyDown(.R) {
		app_randomize(app)
		rl.UpdateTexture(app.screen_tex, app.screen_image.data)
	}

	if !app.running && !rl.IsKeyPressed(.G){
		return
	}

	new_image: rl.Image = rl.GenImageColor(tex_width, tex_height, rl.RAYWHITE)
	for y in 0..<app.screen_image.height {
		for x in 0..<app.screen_image.width {
			new_color := sample_fanbase(app.screen_image, cast(int)x, cast(int)y)
			rl.ImageDrawPixel(&new_image, x, y, new_color)
		}
	}
	rl.UpdateTexture(app.screen_tex, new_image.data)

	// clean up old image and store
	rl.UnloadImage(app.screen_image)
	app.screen_image = new_image
}

draw :: proc(app: ^App) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawTextureEx(app.screen_tex, {0.0, 0.0}, 0.0, tex_scale, rl.WHITE)
	rl.EndDrawing()
}

main :: proc() {
	rl.InitWindow(width, height, "camo-gen")
	defer rl.CloseWindow()

	app: App
	app.screen_image = rl.GenImageColor(tex_width, tex_height, rl.RAYWHITE)
	app_randomize(&app)
	app.screen_tex = rl.LoadTextureFromImage(app.screen_image)

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {
		update(&app)
		draw(&app)
	}

	return
}
