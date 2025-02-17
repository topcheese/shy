// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module main

import shy.lib as shy
import shy.embed

fn main() {
	mut app := &App{}
	shy.run[App](mut app)!
}

[heap]
struct App {
	embed.ExampleApp
}

[markused]
pub fn (mut a App) frame(dt f64) {
	// Draws a hexagon at the center of the window
	a.quick.uniform_poly(
		x: shy.half * a.canvas.width
		y: shy.half * a.canvas.height
		radius: 100
		segments: 6
		stroke: shy.Stroke{
			width: 10
		}
	)
}
