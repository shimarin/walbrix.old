# -*- coding:utf-8 -*-

import pygame

def render_font_with_wordwrap(font, max_width, text, color):
	fullsize = font.size(text)
	if fullsize[0] <= max_width:
		return font.render(text, True, color)
	estimated_length = len(text) * max_width * 3 / fullsize[0] / 2
	head = 0
	tail = estimated_length
	rendered = []

	while head < tail:
		while font.size(text[head:tail])[0] > max_width:
			tail -= 1
			if head == tail:
				break
		rendered.append(font.render(text[head:tail], True, color))
		head = tail
		tail = min(len(text), head + estimated_length)

	height = 0
	for r in rendered:
		height += r.get_height()

	box = pygame.Surface((max_width, height), pygame.SRCALPHA, 32)
	y = 0
	for r in rendered:
		box.blit(r, (0, y))
		y += r.get_height()
	return box

def render_font_with_shadow(font, text, color):
	shadow = font.render(text, True, (0,0,0, 96))
	real = font.render(text, True, color)
	canvas = pygame.Surface(real.get_size(), pygame.SRCALPHA, 32)
	canvas.blit(shadow, (1, 1))
	canvas.blit(real, (0, 0))
	return canvas

def draw_round_rect(surface, color, rect, width, xr, yr):
	clip = surface.get_clip()

	# left and right
	surface.set_clip(clip.clip(rect.inflate(0, -yr*2)))
	pygame.draw.rect(surface, color, rect.inflate(1-width,0), width)

	# top and bottom
	surface.set_clip(clip.clip(rect.inflate(-xr*2, 0)))
	pygame.draw.rect(surface, color, rect.inflate(0,1-width), width)

	# top left corner
	surface.set_clip(clip.clip(rect.left, rect.top, xr, yr))
	pygame.draw.ellipse(surface, color, pygame.Rect(rect.left, rect.top, 2*xr, 2*yr), width)

	# top right corner
	surface.set_clip(clip.clip(rect.right-xr, rect.top, xr, yr))
	pygame.draw.ellipse(surface, color, pygame.Rect(rect.right-2*xr, rect.top, 2*xr, 2*yr), width)

	# bottom left
	surface.set_clip(clip.clip(rect.left, rect.bottom-yr, xr, yr))
	pygame.draw.ellipse(surface, color, pygame.Rect(rect.left, rect.bottom-2*yr, 2*xr, 2*yr), width)

	# bottom right
	surface.set_clip(clip.clip(rect.right-xr, rect.bottom-yr, xr, yr))
	pygame.draw.ellipse(surface, color, pygame.Rect(rect.right-2*xr, rect.bottom-2*yr, 2*xr, 2*yr), width)

	surface.set_clip(clip)

def draw_filled_round_rect_with_frame(surface, bg_color, frame_color, rect, frame_width, xr, yr):
	draw_round_rect(surface, bg_color, rect, 0, xr,yr)
	draw_round_rect(surface, frame_color, rect, frame_width, xr, yr)

def center_to_lefttop(surface, coord):
	x = coord[0]
	y = coord[1]
	return (x - surface.get_width() / 2, y - surface.get_height() / 2)
