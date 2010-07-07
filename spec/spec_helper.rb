$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'RMagick'

module SpecHelper
  SW_MAXIMIZE = 3
  SW_MINIMIZE = 6
  HWND_TOPMOST = -1
  HWND_NOTOPMOST = -2
  SWP_NOSIZE = 1
  SWP_NOMOVE = 2
  SWP_SHOWWINDOW = 40

  extend FFI::Library
  ffi_lib 'user32'
  ffi_convention :stdcall

  # user32.dll
  attach_function :set_window_pos, :SetWindowPos,
                  [:long, :long, :int, :int, :int, :int, :int], :bool

  def check_image(bmp, file=nil)
    File.open("#{file}.bmp", "wb") {|io| io.write(bmp)} unless file.nil?
    bmp[0..1].should == 'BM'
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob {self.format = 'PNG'}
    png[0..3].should == "\211PNG"
    File.open("#{file}.png", "wb") {|io| io.puts(png)} unless file.nil?
  end

  def wait_for_programs_to_open
    until Win32::Screenshot::BitmapMaker.hwnd(/Internet Explorer/) &&
            Win32::Screenshot::BitmapMaker.hwnd(/Notepad/) &&
            Win32::Screenshot::BitmapMaker.hwnd(/Calculator/)
      sleep 0.1
    end
    # just in case of slow PC
    sleep 2
  end

  def maximize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                               SW_MAXIMIZE)
    sleep 1
  end

  def minimize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                               SW_MINIMIZE)
    sleep 1
  end

  def resize title
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    set_window_pos(hwnd,
                   HWND_TOPMOST,
                   0, 0, 150, 238,
                   SWP_NOMOVE)
    set_window_pos(hwnd,
                   HWND_NOTOPMOST,
                   0, 0, 0, 0,
                   SWP_SHOWWINDOW | SWP_NOMOVE | SWP_NOSIZE)
    sleep 1
  end
end
