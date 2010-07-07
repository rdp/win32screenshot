require 'win32/screenshot/bitmap_maker'

module Win32
  # Captures screenshots with Ruby on Windows
  class Screenshot
    class << self

      # captures foreground
      def foreground(&proc)
        hwnd = BitmapMaker.foreground_window
        BitmapMaker.capture_all(hwnd, &proc)
      end

      # captures desktop
      def desktop(&proc)
        hwnd = BitmapMaker.desktop_window
        BitmapMaker.capture_all(hwnd, &proc)
      end

      # captures window with a *title_query* and waits *pause* (by default is 0.5)
      # seconds after trying to set window to the foreground
      def window(title_query, pause=0.5, &proc)
        hwnd = window_hwnd(title_query)
        hwnd(hwnd, pause, &proc)
      end

      # captures area of the window with a *title_query*
      # where *x1* and *y1* are 0 in the upper left corner and
      # *x2* specifies the width and *y2* the height of the area to be captured
      def window_area(title_query, x1, y1, x2, y2, pause=0.5, &proc)
        hwnd = window_hwnd(title_query)
        validate_coordinates(hwnd, x1, y1, x2, y2)
        BitmapMaker.prepare_window(hwnd, pause)
        BitmapMaker.capture_area(hwnd, x1, y1, x2, y2, &proc)
      end
      
      def desktop_area(x1, y1, x2, y2, &proc)
        hwnd = BitmapMaker.desktop_window
        BitmapMaker.capture_area(hwnd, x1, y1, x2, y2, &proc)
      end
        
      # captures by window handle
      def hwnd(hwnd, pause=0.5, &proc)
        BitmapMaker.prepare_window(hwnd, pause)
        BitmapMaker.capture_all(hwnd, &proc)
      end

      private

      def window_hwnd(title_query)
        hwnd = BitmapMaker.hwnd(title_query)
        raise "window with title '#{title_query}' was not found!" unless hwnd
        hwnd
      end

      def validate_coordinates(hwnd, *coords)
        specified_coordinates = coords.join(', ')
        invalid = coords.any? {|c| c < 0}

        x1, y1, x2, y2 = *coords
        invalid ||= x1 >= x2 || y1 >= y2

        max_x1, max_y1, max_x2, max_y2 = BitmapMaker.dimensions_for(hwnd)
        invalid ||= x2 > max_x2 || y2 > max_y2
        raise "specified coordinates (#{specified_coordinates}) are invalid!" if invalid
      end
    end

  end
end
