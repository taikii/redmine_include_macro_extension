Redmine::Plugin.register :redmine_include_macro_extension do
  name 'Include macro extension plugin'
  author 'Taiki IKEGAME'
  description 'This plugin makes possible include wiki section.'
  version '0.0.3'
  url 'https://github.com/taikii/redmine_include_macro_extension'
  author_url 'https://github.com/taikii'

  Redmine::WikiFormatting::Macros.register do

    Redmine::WikiFormatting::Macros::Definitions.send :alias_method, "macro_include_original", "macro_include"

    desc "Includes a wiki page. Examples:\n\n" +
        "{{include(Foo)}}\n" +
        "{{include(Foo, Bar)}} -- to include Bar section of Foo page\n" +
        "{{include(projectname:Foo)}} -- to include a page of a specific project wiki"
    macro :include do |obj, args|
      if args.size == 1
        args.push("DUMMY")
        send("macro_include_original", obj, args)
      else
        page = Wiki.find_page(args.first.to_s, :project => @project)
        raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
        @included_wiki_pages ||= []

        secname = args[1].to_s

        regex = nil
        case Setting.text_formatting
        when "textile"
          regex = '(?:\A|\r?\n\s*\r?\n)h\d+\.[ \t]+(.*?)(?=\r?\n\s*\r?\n|\z)'
        when "markdown"
          regex = '(?:\A|\r?\n)#+ +(.*?)(?=\r?\n|\z)'
        end

        index = 0
        if regex
          page.content.text.scan(/#{regex}/m).each.with_index(1) do |matched, i|
            if matched.first.gsub(/[\r\n]/, '') == secname
              index = i
              break
            end
          end
        end

        sectext = nil
        if index > 0 && Redmine::WikiFormatting.supports_section_edit?
          sectext, hash = Redmine::WikiFormatting.formatter.new(page.content.text).get_section(index)
        end

        raise 'Section not found' if sectext.nil?
        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title) || @included_wiki_pages.include?(page.title + ':' + secname)

        if args.size > 2
          options = args[2..-1]

          if options.include?("nosubsection")
            subsecidx = sectext.index(/#{regex}/m, sectext.index(/#{regex}/m) + 1)
            if subsecidx
              sectext = sectext[0 .. (subsecidx - 1)]
            end
          end
          if options.include?("noheading")
            sectext.sub!(/#{regex}/m, '')
          end
        end

        @included_wiki_pages << page.title + ':' + secname
        out = textilizable(sectext, :attachments => page.attachments, :headings => false)
        @included_wiki_pages.pop
        out
      end
    end
  end
end
