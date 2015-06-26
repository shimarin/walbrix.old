# -*- coding:utf-8 -*-
#@PydevCodeAnalysisIgnore

import pygame
import urllib2
import tarfile
import StringIO

from xml.etree import ElementTree

import main
import messagebox
import resource_loader

# string resources

gui.res.register("string_abort_demo",resource_loader.l({"en":u"Do you want to abort the demo?", "ja":u"デモを中断しますか？"}))

class TerminateDemo(Exception):
	def __init__(self):
		pass

class DemoPlayer:

	def __init__(self, uri, font = None):
		self.uri = uri
		self.font = font

	def load(self):
		source = urllib2.urlopen(self.uri)
		tar = tarfile.open(fileobj=source, mode="r|bz2")

		self.resources = {}
		ti = tar.next()
		while ti != None:
			if ti.name == "script.xml":
				self.script = ElementTree.parse(tar.extractfile(ti))
			else:
				self.resources[ti.name] = tar.extractfile(ti).read()
			ti = tar.next()

		tar.close()
		source.close()

	def draw(self):
		main.screen.blit(main.background, (0,0))

		# draw_contents
		for id in self.objects:
			object = self.objects[id]
			surface = object["surface"]

			x = object["x"]
			y = object["y"]
			if "origin" in object:
				origin = object["origin"]
				if origin == "center":
					x -= surface.get_width() / 2
					y -= surface.get_height() / 2

			if "frame" in object:
				rect = pygame.Rect(x - 5, y - 5, surface.get_width() + 10, surface.get_height() + 10)
				main.draw_filled_round_rect_with_frame(main.screen, (48,48,192,192), (255,255,255), rect, 3, 5, 5)
			main.screen.blit(object["surface"], (x, y))

		main.wallclock.update()
		main.screen.blit(main.wallclock.get_canvas(), (0,0))
		pygame.display.update()

	def get_textrect(self, target = None):
		if target == None:
			target = self.default_textrect
		return self.objects[target]

	def scroll_up(self, surface, dy, div):
		sdy = 0
		amount = dy / div
		for i in range(0, div - 1):
			surface.scroll(0, -amount)
			surface.fill((0,0,0,0), (0,surface.get_height() - amount, surface.get_width(), amount))
			self.draw()
			main.clock.tick(main.frame_rate)
			sdy += amount
		surface.scroll(0, -(dy - sdy))
		surface.fill((0,0,0,0), (0,surface.get_height() - (dy - sdy), surface.get_width(), dy - sdy))
		self.draw()

	def cr(self, target = None):
		textrect = self.get_textrect(target)
		surface = textrect["surface"]
		cx = textrect["cx"]
		cy = textrect["cy"]

		if cx > 0:
			cx = 0
			font_height = self.font.get_height()
			cy += font_height
			if font_height + cy > surface.get_height():
				dy = font_height + cy - surface.get_height()
				self.scroll_up(surface, dy, 4)
				cy -= dy
			textrect["cx"] = cx
			textrect["cy"] = cy


	def putchar(self, c, target = None):
		textrect = self.get_textrect(target)
		surface = textrect["surface"]
		cx = textrect["cx"]
		cy = textrect["cy"]
		char = self.font.render(c, True, (255,255,255))
		if char.get_width() + cx > surface.get_width():
			cx = 0
			cy += char.get_height()
			if char.get_height() + cy > surface.get_height():
				dy = char.get_height() + cy - surface.get_height()
				self.scroll_up(surface, dy, 4)
				cy -= dy

		surface.blit(char, (cx, cy))
		cx += char.get_width()
		textrect["cx"] = cx
		textrect["cy"] = cy

	def cancel_key(self):
		if messagebox.message_box(gui.res.string_abort_demo, ["ok", "cancel"]) == "ok":
			raise TerminateDemo()

	def wait_for_key(self, timeout=-1):
		time = 0
		time_up = timeout * main.frame_rate
		while True:
			main.clock.tick(main.frame_rate)
			for event in pygame.event.get():
				if main.is_select_event(event):
					return
				elif main.is_cancel_event(event):
					self.cancel_key()

			self.draw()
			time += 1
			if timeout >= 0 and time >= time_up:
				return

	def process_element(self, elem):
		if elem.tag == "image":
			id = elem.get("id")
			src = elem.get("src")
			x = elem.get("x")
			y = elem.get("y")
			self.objects[id] = {"surface":pygame.image.load(StringIO.StringIO(self.resources[src])).convert_alpha(),"x":int(x),"y":int(y)}
			origin = elem.get("origin")
			if origin != None:
				self.objects[id]["origin"] = origin
			self.draw()

		elif elem.tag == "textrect":
			id = elem.get("id")
			x = elem.get("x")
			y = elem.get("y")
			width = elem.get("width")
			height = elem.get("height")
			self.objects[id] = {"surface":pygame.Surface((int(width),int(height)), pygame.SRCALPHA, 32),"x":int(x),"y":int(y),"cx":0,"cy":0,"frame":True}
			self.default_textrect = id
        
		elif elem.tag == "sentence":
			text = elem.text
			if text == None:
				return
			skip = False
			for c in text:
				if not skip:
					main.clock.tick(main.frame_rate)
				for event in pygame.event.get():
					if main.is_select_event(event):
						skip = True
					elif  main.is_cancel_event(event):
						self.cancel_key()
				self.putchar(c)
				if not skip:
					self.draw()
			self.cr()
			if skip:
				self.draw()
			self.wait_for_key(0.05 * len(text))
		elif elem.tag == "clear-textrect":
			textrect = self.get_textrect()
			textrect["surface"].fill((0,0,0,0))
			textrect["cx"] = 0
			textrect["cy"] = 0

		elif elem.tag == "remove":
			target = elem.get("target")
			del self.objects[target]

		elif elem.tag == "fadeout":
			pass

	def play(self):
		self.load()
		self.objects = {}

		try:
			for e in self.script.findall("/*"):
				self.process_element(e)
		except TerminateDemo:
			pass


