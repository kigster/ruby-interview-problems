# frozen_string_literal: true

require 'tty/box'
require 'tty/screen'
require 'tty/cursor'

module Cloud
  module Kitchens
    module Dispatch
      module UI
        StackTraceFrame = Struct.new(:file, :lineno, :method_name) do
          def initialize(backtrace)
            backtrace.gsub!(%r[.*lib/cloud/kitchens], '')

            Gem.path.each do |p|
              backtrace.gsub! /#{p}/, ''
            end

            path, method_name = *backtrace.split(':in ')
            file, lineno = *path.split(':')

            file   = sprintf('%45.45s', file)
            lineno = sprintf('%4d', lineno.to_i)
            method_name = sprintf('%-30s', "#{method_name.gsub(/[`']/, '')}()")

            super(file, lineno, method_name)
          end

          def to_s
            pw = App.screen_width - 10
            sprintf "%-#{pw}.#{pw}s", "line #{lineno}, #{file} -> #{method_name}"
          end
        end

        class << self
          def included(base)
            base.include(UI::InstanceMethods)
          end
        end

        module InstanceMethods
          def text_box(title: nil, text: [], stream: $stdout, **options)
            cursor options[:cursor_action_before] if options[:cursor_action_before]

            stream.print TTY::Box.frame(
              width: TTY::Screen.width,
              **default_box_options(color: :bright_yellow).merge(default_box_options(title: title))
            ) do
              text.is_a?(Array) ? text.join("\n") : text.to_s
            end

            cursor options[:cursor_action_after] if options[:cursor_action_after]
          end

          def ui_width
            TTY::Screen.columns
          end

          def hr(stream: $stdout)
            stream.puts('—' * (ui_width - 2)).to_s.blue
          end

          def error(*args, stream: $stdout)
            stream.print TTY::Box.error(args.join("\n"), **default_box_options)
          end

          def warn(*args, stream: $stdout)
            stream.print TTY::Box.warn(args.join("\n"), **default_box_options(color: :bright_yellow))
          end

          def info(*args, stream: $stdout)
            stream.print TTY::Box.info(args.join("\n"), **default_box_options(color: :bright_green))
          end

          def cursor(method = nil, *args, stream: $stdout)
            (@cursor ||= TTY::Cursor).tap do |csr|
              if method
                stream.print csr.send(method, *args)
              end
            end
          end

          def clear_screen!(stream: $stdout)
            stream.print TTY::Cursor.clear_screen
          end

          def default_box_options(title: nil, color: :bright_yellow)
            {
              width:   ui_width,
              align:   :left,
              border:  :light,
              padding: [0, 1, 0, 1],
              style:   {
                fg:     color,
                border: { fg: color }
              },
              title:   { top_center: title.nil? ? Time.new.to_s : title },
            }
          end

          def test?
            ::Cloud::Kitchens::Dispatch.in_test
          end

          def backtrace_trim(error)
            return nil if error.backtrace.nil? || error.backtrace&.empty?

            error.backtrace.map do |backtrace|
              UI::StackTraceFrame.new(backtrace)
            end.map(&:to_s).join("\n")
          end

          def print_header(stream: $stdout)
            box_opts = box_args(bg: :black, fg: :bright_green)
            stream.puts TTY::Box.frame(
              *Identity::HEADER,
              **box_opts
            )
            stream.puts cursor.down(2)
          end

          def box(title, *text, stream: $stdout)
            box_opts = box_args(bg: :magenta, fg: :white, title: title)

            stream.puts TTY::Box.frame(
              *text,
              **box_opts
            )

            stream.puts cursor.down(2)
          end

          def argv?(flags)
            flags = Array(flags).flatten
            !(flags & argv).empty?
          end

          def error_box(error, stream: $stdout, **opts)
            stream.print cursor.down(5)
            TTY::Box.frame(**box_args(**opts)) do
              case error
              when Dry::CLI::Error
                error.message
              when StandardError
                error.message
              when Array
                error.join("\n")
              else
                error.to_s
              end
            end
          end

          def box_args(bg: :red, fg: :black, w: App.screen_width, title: nil)
            title      = " « #{title} » " if title
            title_opts = if title
                           { top_center: title }
                         else
                           { top_left: Time.now.to_s, top_right: Identity::VERSION_LABEL }
                         end

            { width:   w,
              title:   title_opts,
              padding: 1,
              align:   :left,
              border:  :thick,
              style:   {
                bg:     bg,
                fg:     fg,
                border: { bg: bg, fg: :white },
              }, }
          end

          def process_error(e, stream: $stderr)
            raise(e) if test?

            $stderr.print "\n#{error_box(e, title: 'EXCEPTION', stream: stream)}"
            if trace
              $stdout.print cursor.up(1)
              $stderr.print error_box(backtrace_trim(e), title: 'STACKTRACE', fg: :white, stream: stream)
            end
            $stdout.print cursor.down(2)
          end
        end
      end
    end
  end
end
