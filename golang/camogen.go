package main

import "fmt"

func main() {
	t := NewTexture(640, 480)
	t.SetPixel(0, 0, 0xff0000)
	fmt.Println(t.GetPixel(0, 0))
}

type Texture struct {
	width       int
	height      int
	data_buffer []uint8
}

func NewTexture(width int, height int) *Texture {
	t := Texture{width, height, make([]byte, (width+4)*height)}
	return &t
}

func (tex *Texture) SetPixel(x int, y int, color int) {
	offset := y*(tex.width*4) + (x * 4)
	tex.data_buffer[offset+0] = uint8((color & 0xFF0000) >> 16)
	tex.data_buffer[offset+1] = uint8((color & 0x00FF00) >> 8)
	tex.data_buffer[offset+2] = uint8(color & 0x0000FF)
}

func (tex *Texture) GetPixel(x int, y int) int {
	offset := y*(tex.width*4) + (x * 4)
	red := tex.data_buffer[offset+0]
	green := tex.data_buffer[offset+1]
	blue := tex.data_buffer[offset+2]

	return (int(red) << 16) | (int(green) << 8) | int(blue)
}
