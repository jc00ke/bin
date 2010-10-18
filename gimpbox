#!/usr/bin/python
# -*- coding: UTF-8 -*-
'''gimpbox.py

启动单窗口的 Gimp

用法:
    python gimpbox.py
    或
    gimp & sleep 5s ; python gimpbox.py

'''

import gtk, gobject
import wnck
import time
import os
import sys

import gettext
gettext.install('gimp20')
STR_GIMP = _('GNU Image Manipulation Program') or 'GNU 图像处理程序'
STR_TOOLBOX = _('Toolbox') or '工具箱'
STR_LAYER = _('Layer') or '图层'

def get_screenshot_thumb(drawable, width=32, height=32):
    w, h = drawable.get_size()
    ## gimp 图像窗口截图时减去菜单栏等非图像区域
    x = 15
    y = 45
    w = w - x
    h = h - y - 32
    screenshot = gtk.gdk.Pixbuf.get_from_drawable(
        gtk.gdk.Pixbuf(gtk.gdk.COLORSPACE_RGB, True, 8, w, h),
        drawable,
        gtk.gdk.colormap_get_system(),
        x, y, 0, 0, w, h)
    #screenshot.save(filename, 'png')
    if not screenshot:
        return None
    return screenshot.scale_simple(width, height, gtk.gdk.InterpType(2))

class mainwindow:
    '''主窗口
    '''
    def __init__(self, create = True, accel_group = None, tooltips = None):
        '''建立主窗口和布局
        '''

        self.mainwindow = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.mainwindow.set_icon_name("gimp")
        self.mainwindow.set_default_size(700, 500)
        self.mainwindow.maximize()
        self.mainwindow.set_title(_("GimpBox"))
        #self.mainwindow.set_position(gtk.WIN_POS_CENTER)
        self.mainwindow.show()
        self.mainwindow.connect("delete_event", self.quit)

        self.screen = wnck.screen_get_default()

        self.hpaned1 = gtk.HPaned()
        self.hpaned1.set_position(180)
        self.hpaned1.show()

        self.toolboxarea = gtk.Socket()
        self.toolboxarea.show()
        self.hpaned1.pack1(self.toolboxarea, False, True)

        self.hpaned2 = gtk.HPaned()
        self.hpaned2.show()

        self.notebook = gtk.Notebook()
        self.notebook.set_tab_pos(gtk.POS_BOTTOM)
        self.notebook.popup_enable()
        self.notebook.set_scrollable(True)
        self.notebook.show()

        self.hpaned2.pack1(self.notebook, False, True)

        self.miscboxarea = gtk.Socket()
        self.miscboxarea.show()
        self.hpaned2.pack2(self.miscboxarea, False, False)

        self.hpaned1.pack2(self.hpaned2, True, True)

        self.mainwindow.add(self.hpaned1)

        gobject.idle_add(self.start)
        #self.toolboxarea.connect('realize', self.start)

        self.mainwindow.show_all()
        pass

    def start(self, *args):
        '''开始处理
        '''
        self.hpaned2.set_position(self.hpaned2.get_allocation()[2] - 180)
        self.query_windows()
        gobject.timeout_add(2000, self.update_thumb)
        pass

    def _on_window_open(self, screen, wnck_window):
        '''新窗口事件
        '''
        gobject.timeout_add(2000, self.proc_window, wnck_window)
        pass

    def proc_window(self, wnck_window, *args):
        '''挑选窗口
        '''
        if not wnck_window.get_application():
            return
        if wnck_window.get_application().get_icon_name() != STR_GIMP:
            return
        if wnck_window.get_window_type() == wnck.WINDOW_UTILITY:
            if wnck_window.get_icon_name().startswith(STR_TOOLBOX):
                self._add_wnck_window_to_drawingarea(wnck_window, self.toolboxarea)
                pass
            elif STR_LAYER in wnck_window.get_icon_name():
                self._add_wnck_window_to_drawingarea(wnck_window, self.miscboxarea)
                pass
            pass
        elif wnck_window.get_window_type() == wnck.WINDOW_NORMAL:
            if wnck_window.get_icon_name().startswith('GNU') \
                    or wnck_window.get_icon_name().endswith('GIMP') \
                    or wnck_window.get_icon_name().endswith('GNU'):
                self.add_wnck_window_to_tab(wnck_window)
                pass
            pass
        pass

    def query_windows(self):
        '''遍历现有窗口
        '''
        for w in self.screen.get_windows_stacked():
            gobject.timeout_add(500, self.proc_window, w)
            pass
        if not self.tabs:
            if sys.argv[1:]:
                os.popen('(sleep 0.5 ; gimp %s & ) &' % (' '.join([ '"%s"' % i.replace('"', '\\"') for i in sys.argv[1:] ])))
                pass
            else:
                os.popen('(sleep 0.5 ; gimp & ) &')
                pass
            pass
        self.screen.connect('window-opened', self._on_window_open)
        pass

    def _on_add_wnck_window_to_drawingarea(self, widget, wnck_window, drawingarea=None):
        self._add_wnck_window_to_drawingarea(wnck_window, drawingarea)
        pass

    def _add_wnck_window_to_drawingarea(self, wnck_window, drawingarea=None):
        '''真正将窗口曳入标签
        '''
        drawingarea.wnck_window = wnck_window
        return drawingarea.add_id(wnck_window.get_xid())

    def on_tab_window_name_change(self, wnck_window, drawingarea):
        '''处理窗口标题
        '''
        name = wnck_window.get_name()
        drawingarea.tabmenu.set_text(name)
        pass

    def on_tab_window_icon_change(self, wnck_window, drawingarea):
        '''处理窗口图标
        '''
        icon = wnck_window.get_icon()
        drawingarea.tabimage.set_from_pixbuf(icon)
        pass

    def update_thumb(self):
        '''更新标签栏缩略图
        '''
        if self.notebook.get_n_pages():
            box = self.notebook.get_nth_page( self.notebook.get_current_page() )
            if not box.window:
                return True
            pixbuf = get_screenshot_thumb(box.window, 48, 48)
            if not pixbuf:
                return True
            img = self.notebook.get_tab_label(box)
            if img.get_pixbuf() != pixbuf:
                img.set_from_pixbuf(pixbuf)
                img.show()
                pass
            pass
        return True

    def _tab_remove(self, drawingarea):
        '''当标签页有窗口关闭
        '''
        box = drawingarea.parent
        self.notebook.remove(box)
        wnck_window = drawingarea.wnck_window
        if wnck_window in self.tabs:
            del self.tabs[wnck_window]
            pass
        if not self.notebook.get_n_pages():
            self.quit()
            pass
        pass

    tabs = {}
    def add_wnck_window_to_tab(self, wnck_window):
        '''将窗口添加到标签
        '''
        notebook = self.notebook
        drawingarea = gtk.Socket()
        drawingarea.show()
        drawingarea.connect('realize', self._on_add_wnck_window_to_drawingarea, wnck_window, drawingarea)
        drawingarea.connect('plug-removed', self._tab_remove)
        tabimage = gtk.Image()
        tabimage.set_from_pixbuf(wnck_window.get_icon())
        tabimage.set_padding(0, 0)
        tabimage.show()
        tabmenu = gtk.Label(wnck_window.get_name())

        box = gtk.Viewport()
        box.add(drawingarea)
        box.show()

        box.set_flags(gtk.CAN_FOCUS)

        drawingarea.box = box
        drawingarea.tabimage = tabimage
        drawingarea.tabmenu = tabmenu
        drawingarea.wnck_window = wnck_window

        notebook.append_page_menu(box, tabimage, tabmenu)
        notebook.set_current_page( notebook.page_num(box) )

        notebook.set_tab_reorderable(drawingarea, 1)

        self.tabs[wnck_window] = drawingarea

        pass

    def quit(self, *args):
        gtk.main_quit()
        pass


if __name__ == '__main__':
    win=mainwindow()
    gtk.main()

