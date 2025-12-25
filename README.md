# GLSL Std140 and Std430 Layout Calculator
Reference: https://registry.khronos.org/OpenGL/specs/gl/glspec46.core.pdf pages 146-147

## Usage
Feed it input through stdin. By default the program calculator `std140` layout, the `--std430` flag switches it to `std430`. \
Example input (similar to glsl):
```
vec3 position
float rotation
vec2 scale
vec2 padding
float texu
float texv
float texw
float texh
vec4 color
```
or with explicit blocks
```
#structure light
vec4 position
float strength
float parameters[3]

#uniform main
mat4 view
light lights[32]
```

## TODO
- [x] Input
- [x] Array of structs
- [x] Parse structures
- [x] flag for std140 vs 430
- [ ] More helpful array output
- [ ] parse "buffers" (with unsized array)

- [ ] web version
- [ ] blog post

