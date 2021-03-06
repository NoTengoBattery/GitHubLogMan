#!/usr/bin/env ruby

require_relative '../lib/provider'
require_relative '../lib/printer'
require_relative '../lib/argparser'

Blessings.output_stream = $stderr
MORE_HELP = 'For more information about the usage of this script, run it with the -h flag.'.freeze

begin
  options = ScriptOptparser.new.parse(ARGV)
rescue OptionParser::ParseError => e
  MyUtils.exit_on_exception(e, MORE_HELP, PARSER_ECODE)
end
MyUtils.verbose = options.verbose
MyUtils.quiet = options.quiet

MyUtils.pwarn('The program has started. Please wait while the request is completed...')
MyUtils.pwarn(nil)
MyUtils.note('This process may take a while, specially for large changelogs.')
MyUtils.note('Enable the verbose mode to see the proccess as it runs.')
MyUtils.note('The script may fail due to excessive request to the provider, be careful to not hit the limit.')
MyUtils.note(nil)
MyUtils.note(MORE_HELP)
begin
  scraper = ProviderFactory.build(options.url)
  scraper.build_from(options.url)
rescue NoProviderError => e
  MyUtils.exit_on_exception(
    e, "Run this scirpt with the verbose option to see all the available providers.\n#{MORE_HELP}",
    PROVIDER_ECODE
  )
rescue HTTP::ConnectionError => e
  MyUtils.exit_on_exception(
    e, "Provide a valid URL and ensure a stable internet connection.\n#{MORE_HELP}",
    HTTP_ECODE
  )
rescue ScraperError => e
  e.backtrace
  MyUtils.exit_on_exception(
    e, "Please report this issue to the maintainer. Enable the verbose mode and send a copy of the log.\n#{MORE_HELP}",
    SCRAPER_ECODE
  )
end
MyUtils.note('All information was correctly retrieved from the internet')

begin
  printer = PrinterFactory.build(options.printer)
  printer.print_changelog(scraper.changelog)
rescue Curses::Error => e
  e.backtrace
  MyUtils.exit_on_exception(
    e, "The Curses printer failed. This error can happen for two reasons:
\t1. The screen is too small: please resize your screen
\t2. This console does not support all curses functions: use other terminal emulator or TTY
If you are using repl.it, the repl.it Console does not support resizing and Shell/Console does not support UTF-8.
Please run this script in your local machine, most Linux terminal emulators and WSL support all functionality.
#{MORE_HELP}",
    PRINTER_ECODE
  )
end
