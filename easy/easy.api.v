// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module easy

import shy.lib as shy
import shy.vec
import shy.mth
import shy.particle
// High-level as-easy-as-it-gets API

// $if !shy_easy ? {
//	$compile_error('Please use `v -d shy_easy ...` when building or running this module')
// }

// Quick is an internal struct for fire-and-forget/instant calling of Easy methods.
//[noinit]
pub struct Quick {
pub mut: // TODO error: field ... is not public - make this just "pub" to callers - and mut to internal system
	easy &Easy = shy.null
}

[heap]
pub struct Easy {
	shy.ShyStruct
mut:
	quick            Quick
	audio_engine     &shy.AudioEngine = shy.null
	particle_systems []&particle.System
}

pub fn (mut e Easy) init() ! {
	e.quick.easy = e
	e.audio_engine = e.shy.audio().engine(0)!
	// e.particle_systems TODO init a limited amount of systems
}

pub fn (mut e Easy) shutdown() ! {
	for mut ps in e.particle_systems {
		ps.free()
		// free(ps)
	}
	e.particle_systems.clear()
}

pub fn (mut e Easy) variable_update(dt f64) {
	for mut ps in e.particle_systems {
		ps.update(dt)
	}
}

[params]
pub struct EasyTextConfig {
pub mut:
	x        f32
	y        f32
	rotation f32
	scale    f32 = 1.0
	text     string
	size     f32 = shy.defaults.font.size
	origin   shy.Anchor
	align    shy.TextAlign = .baseline | .left
	offset   vec.Vec2[f32]
	color    shy.Color = shy.rgba(255, 255, 255, 255) // BUG shy.defaults.font.color
	blur     f32
}

[noinit]
pub struct EasyText {
	shy.ShyStruct
pub mut:
	x        f32
	y        f32
	rotation f32
	scale    f32 = 1.0
	text     string
	size     f32 = shy.defaults.font.size
	origin   shy.Anchor
	align    shy.TextAlign = .baseline | .left
	offset   vec.Vec2[f32]
	color    shy.Color = shy.defaults.font.color
	blur     f32
}

[inline]
pub fn (et &EasyText) draw() {
	draw := et.shy.draw()
	mut dt := draw.text()
	dt.begin()
	mut t := dt.text_2d()
	t.text = et.text
	t.x = et.x
	t.y = et.y
	t.rotation = et.rotation
	t.scale = et.scale
	t.size = et.size
	t.origin = et.origin
	t.align = et.align
	t.offset = et.offset
	t.color = et.color
	t.blur = et.blur
	t.draw()
	dt.end()
}

[inline]
pub fn (et &EasyText) bounds() shy.Rect {
	draw := et.shy.draw()
	mut dt := draw.text()
	dt.begin()
	defer {
		dt.end()
	}
	mut t := dt.text_2d()
	t.text = et.text
	t.x = et.x
	t.y = et.y
	t.rotation = et.rotation
	t.scale = et.scale
	t.size = et.size
	t.origin = et.origin
	t.align = et.align
	t.offset = et.offset
	t.color = et.color
	t.blur = et.blur
	return t.bounds(t.text)
}

[inline]
pub fn (e &Easy) new_text(etc EasyTextConfig) &EasyText {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return &EasyText{
		...etc
		shy: e.shy
	}
}

[inline]
pub fn (e &Easy) text(etc EasyTextConfig) EasyText {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyText{
		...etc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) text(etc EasyTextConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.text(etc).draw()
}

// Shape drawing sub-system

// Rect

[params]
pub struct EasyRectConfig {
	shy.Rect
pub mut:
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor
}

[noinit]
pub struct EasyRect {
	shy.ShyStruct
	shy.Rect
pub mut:
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor
}

[inline]
pub fn (er &EasyRect) draw() {
	draw := er.shy.draw()
	mut d := draw.shape_2d()
	d.begin()
	mut r := d.rect()
	r.x = er.x
	r.y = er.y
	r.width = er.width
	r.height = er.height
	r.stroke = er.stroke
	r.rotation = er.rotation
	r.scale = er.scale
	r.color = er.color
	r.fills = er.fills
	r.offset = er.offset
	r.origin = er.origin
	r.draw()
	d.end()
}

[inline]
pub fn (e &Easy) rect(erc EasyRectConfig) EasyRect {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyRect{
		...erc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) rect(erc EasyRectConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.rect(erc).draw()
}

// Triangle

[params]
pub struct EasyTriangleConfig {
pub mut:
	a        vec.Vec2[f32]
	b        vec.Vec2[f32]
	c        vec.Vec2[f32]
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor
}

[noinit]
pub struct EasyTriangle {
	shy.ShyStruct
pub mut:
	a        vec.Vec2[f32]
	b        vec.Vec2[f32]
	c        vec.Vec2[f32]
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor
}

[inline]
pub fn (et &EasyTriangle) bbox() shy.Rect {
	t := shy.Triangle{
		a: et.a
		b: et.b
		c: et.c
	}
	bb := t.bbox()
	mut p_x, mut p_y := et.origin.pos_wh(bb.width, bb.height)
	return shy.Rect{
		x: bb.x - p_x
		y: bb.y - p_y
		width: bb.width
		height: bb.height
	}
}

[inline]
pub fn (et &EasyTriangle) draw() {
	draw := et.shy.draw()
	mut d := draw.shape_2d()
	d.begin()
	mut t := d.triangle()
	t.Triangle.a = et.a
	t.Triangle.b = et.b
	t.Triangle.c = et.c
	t.stroke = et.stroke
	t.rotation = et.rotation
	t.scale = et.scale
	t.color = et.color
	t.fills = et.fills
	t.offset = et.offset
	t.origin = et.origin
	t.draw()
	d.end()
}

[inline]
pub fn (e &Easy) triangle(etc EasyTriangleConfig) EasyTriangle {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyTriangle{
		...etc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) triangle(etc EasyTriangleConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.triangle(etc).draw()
}

// Line

[params]
pub struct EasyLineConfig {
	shy.Line
	shy.Stroke
pub mut:
	rotation f32
	scale    f32 = 1.0
	ray      bool
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center_left
}

[noinit]
pub struct EasyLine {
	shy.ShyStruct
	shy.Line
	shy.Stroke
pub mut:
	rotation f32
	scale    f32 = 1.0
	ray      bool
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center_left
}

[inline]
pub fn (el &EasyLine) draw() {
	draw := el.shy.draw()
	mut d := draw.shape_2d()
	d.begin()
	mut l := d.line_segment()
	l.a = el.a
	l.b = el.b
	if el.ray {
		// Draw line as a ray - this is basically just done by extending the line towards the
		// drawable area's edges - giving an illusion of an "infinite" ray passing through the drawable area.
		mut nl := EasyLine{
			a: el.a
			b: el.b
		}
		// point a should always be the left-most point
		nl.ensure_a_left_b_right()
		w, h := el.shy.active_window().drawable_wh()
		// TODO do something less wasteful here?
		grow := mth.max(w, h) * 2
		nl.grow_a(-grow)
		nl.grow_b(grow)
		l.a = nl.a
		l.b = nl.b
	}
	l.Stroke = el.Stroke
	l.rotation = el.rotation
	l.scale = el.scale
	l.offset = el.offset
	l.origin = el.origin
	l.draw()
	d.end()
}

[inline]
pub fn (e &Easy) line_segment(elc EasyLineConfig) EasyLine {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyLine{
		...elc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) line_segment(elc EasyLineConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.line_segment(elc).draw()
}

// Circle

[params]
pub struct EasyCircleConfig {
	shy.Circle
pub mut:
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center
}

[noinit]
pub struct EasyCircle {
	shy.ShyStruct
	shy.Circle
pub mut:
	stroke   shy.Stroke
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center
}

[inline]
pub fn (ec &EasyCircle) draw() {
	draw := ec.shy.draw()
	mut d := draw.shape_2d()
	d.begin()
	mut c := d.circle(radius: ec.radius) // NOTE this is here to let radius_to_segments have an effect
	c.x = ec.x
	c.y = ec.y
	// c.radius = ec.radius
	c.stroke = ec.stroke
	c.rotation = ec.rotation
	c.scale = ec.scale
	c.color = ec.color
	c.fills = ec.fills
	c.offset = ec.offset
	c.origin = ec.origin
	c.draw()
	d.end()
}

[inline]
pub fn (e &Easy) circle(ecc EasyCircleConfig) EasyCircle {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyCircle{
		...ecc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) circle(ecc EasyCircleConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.circle(ecc).draw()
}

// Uniform Polygon

[params]
pub struct EasyUniformPolyConfig {
	shy.Circle
pub mut:
	stroke   shy.Stroke
	segments u32 = 3
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center
}

[noinit]
pub struct EasyUniformPoly {
	shy.ShyStruct
	shy.Circle
pub mut:
	stroke   shy.Stroke
	segments u32 = 3
	rotation f32
	scale    f32       = 1.0
	color    shy.Color = shy.colors.shy.red
	fills    shy.Fill  = .body | .stroke
	offset   vec.Vec2[f32]
	origin   shy.Anchor = .center
}

[inline]
pub fn (eup &EasyUniformPoly) draw() {
	draw := eup.shy.draw()
	mut d := draw.shape_2d()
	d.begin()
	mut up := d.uniform_poly(segments: eup.segments)
	up.x = eup.x
	up.y = eup.y
	up.radius = eup.radius
	up.stroke = eup.stroke
	up.rotation = eup.rotation
	up.scale = eup.scale
	up.color = eup.color
	up.fills = eup.fills
	up.offset = eup.offset
	up.origin = eup.origin
	up.draw()
	d.end()
}

[inline]
pub fn (e &Easy) uniform_poly(eupc EasyUniformPolyConfig) EasyUniformPoly {
	assert !isnil(e.shy), 'Easy struct is not initialized'
	return EasyUniformPoly{
		...eupc
		shy: e.shy
	}
}

[inline]
pub fn (q &Quick) uniform_poly(eupc EasyUniformPolyConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.uniform_poly(eupc).draw()
}

// Audio sub-system

// [noinit]
// pub struct EasySound {
// 	shy.ShyStruct
// 	engine &shy.AudioEngine
// 	id     u16
// 	id_end u16
// pub mut:
// 	loop bool
// }

// [params]
// pub struct EasySoundConfig {
// 	source      shy.AssetSource
// 	loop        bool
//  	max_repeats u8 // number of copies of the sound, needed to support repeated playback of the same sound
// }

[params]
pub struct EasySoundPlayOptions {
	source shy.AssetSource [required]
	loops  u16
	pitch  f32
	volume f32 = 1.0
}

[inline]
pub fn (q &Quick) play(opt EasySoundPlayOptions) {
	assert !isnil(q.easy), 'Easy struct is not initialized'

	// TODO
	mut sound := unsafe {
		q.easy.shy.assets().get[shy.Sound](opt.source) or {
			panic('${@STRUCT}.${@FN}: TODO ${err}')
		}
	}

	sound.pitch = opt.pitch
	sound.volume = opt.volume
	// TODO sounds.loop = true - but the counter needs state?
	// sound.loops
	sound.play()
}

// pub fn (e &Easy) new_sound(esc EasySoundConfig) !&EasySound {
// 	assert !isnil(e.shy), 'Easy struct is not initialized'
// 	e.shy.vet_issue(.warn, .hot_code, '${@STRUCT}.${@FN}', 'memory fragmentation can happen when allocating in hot code paths. It is, in general, better to pre-load data.')
// 	mut audio := e.audio_engine

// 	mut id := u16(0)
// 	mut id_end := u16(0)
// 	if esc.max_repeats > 1 {
// 		id, id_end = audio.load_copies(esc.path, esc.max_repeats)!
// 	} else {
// 		id = audio.load(esc.path)!
// 	}
// 	return &EasySound{
// 		shy: e.shy
// 		engine: e.audio_engine
// 		id: id
// 		id_end: id_end
// 		loop: esc.loop
// 	}
// }

pub struct EasyImageConfigRect {
	x      f32
	y      f32
	width  f32 = -1
	height f32 = -1
}

// Image drawing sub-system
[params]
pub struct EasyImageConfig {
	// shy.Rect: shy.Rect{0,0,-1,-1}
	EasyImageConfigRect
pub:
	source    shy.AssetSource
	color     shy.Color = shy.rgb(255, 255, 255)
	rotation  f32
	scale     f32 = 1.0
	offset    vec.Vec2[f32]
	origin    shy.Anchor
	region    shy.Rect = shy.Rect{0, 0, -1, -1}
	fill_mode shy.ImageFillMode
}

[noinit]
pub struct EasyImage {
	shy.ShyStruct
	shy.Rect
pub:
	source    shy.AssetSource
	color     shy.Color = shy.rgb(255, 255, 255)
	rotation  f32
	scale     f32 = 1.0
	offset    vec.Vec2[f32]
	origin    shy.Anchor
	region    shy.Rect = shy.Rect{0, 0, -1, -1}
	fill_mode shy.ImageFillMode
}

pub fn (ei &EasyImage) draw() {
	if image := ei.shy.assets().get[shy.Image](ei.source) {
		// if img := ei.shy.assets().get_cached_image(ei.source) {

		draw := ei.shy.draw()
		mut d := draw.image()
		d.begin()
		mut i2d := d.image_2d(image)
		i2d.x = ei.x
		i2d.y = ei.y
		i2d.width = ei.width
		i2d.height = ei.height
		i2d.color = ei.color
		i2d.rotation = ei.rotation
		i2d.scale = ei.scale
		i2d.offset = ei.offset
		i2d.origin = ei.origin
		i2d.fill_mode = ei.fill_mode

		if ei.region.width >= 0 || ei.region.height >= 0 {
			src := shy.Rect{
				x: 0
				y: 0
				width: ei.width
				height: ei.height
			}
			dst := ei.region
			// println('$ei.source:\nsrc: $src dst: $dst')
			i2d.draw_region(src, dst)
		} else {
			i2d.draw()
		}
		d.end()
	}
}

[inline]
pub fn (e &Easy) image(eic EasyImageConfig) EasyImage {
	assert !isnil(e.shy), 'Easy struct is not initialized'

	if image := e.shy.assets().get[shy.Image](eic.source) {
		// if img := e.shy.assets().get_cached_image(eic.source) {
		mut r := shy.Rect{
			x: eic.x
			y: eic.y
		}
		r.width = if eic.width < 0 { f32(image.width) } else { eic.width }
		r.height = if eic.height < 0 { f32(image.height) } else { eic.height }

		// TODO WORKAROUND "...eic" spread does not work
		// with the EasyImageConfigRect, which is there because we can't initialize the embedded shy.Rect with other values :(
		return EasyImage{
			shy: e.shy
			Rect: r
			// y: r.y
			// w: r.width
			// h: r.height
			source: eic.source
			color: eic.color
			rotation: eic.rotation
			scale: eic.scale
			offset: eic.offset
			origin: eic.origin
			region: eic.region
			fill_mode: eic.fill_mode
		}
	}
	// return
	// TODO
	panic('${@STRUCT}.${@FN}: "${eic.source}" not found in cache, please load it')
}

[inline]
pub fn (q &Quick) image(eic EasyImageConfig) {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	q.easy.image(eic).draw()
}

// Assets
// load returns a reference `shy.Asset`. Note that the asset may not be fully loaded
// depending on the load options passed.
pub fn (e &Easy) load(alo shy.AssetLoadOptions) !&shy.Asset {
	mut assets := e.shy.assets()
	return assets.load(alo)!
}

[inline]
pub fn (q &Quick) load(ao shy.AssetOptions) ! {
	assert !isnil(q.easy), 'Easy struct is not initialized'
	assets := q.easy.shy.assets()
	mut asset := q.easy.load(ao.AssetLoadOptions)!
	match ao {
		shy.ImageOptions {
			// TODO e.shy.assets.is_cached(...) ???
			if _ := assets.get[shy.Image](ao.source) {
				// if _ := assets.get_cached_image(ao.source) {
				// assets.get[&shy.Asset](ao.source)
				return
			}
			_ := asset.to[shy.Image](ao)!
			// return image
			return
		}
		shy.SoundOptions {
			_ := asset.to[shy.Sound](ao)!
			return
		}
	}
	return error('${@STRUCT}.${@FN}: TODO ${ao} type not implemented yet')
}
