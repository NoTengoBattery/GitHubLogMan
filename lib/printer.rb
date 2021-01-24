#!/usr/bin/env ruby

require_relative 'git'

class NoPrinterError < StandardError; end

module Printer
  def initialize(*); end

  def supports?(keyword)
    keyword == @keyword
  end

  def print_changelog(*)
    raise(NotImplementedError, "Please create a printer that inherits from #{Printer} and implement `print_changelog`")
  end
end

require_relative 'outputs'

# Add new printer here by pushing the class into the @printers array. Do not modify anything else.
class PrinterFactory
  def initialize
    @printers = []
    @printers << Pipe
  end

  def build(keyword)
    @printers.each do |printer|
      MyUtils.pinfo("Checking if printer '#{printer}' can handle the selected printer...")
      printer_built = printer.new
      return printer_built if printer_built.supports?(keyword)

      MyUtils.pinfo("Printer '#{printer}' can not handle the selected printer")
    end
    raise(NoPrinterError, "There is no #{Printer} that can handle '#{keyword}'")
  end
end