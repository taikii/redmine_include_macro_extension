Redmine::Plugin.register :redmine_include_macro_extension do
  name 'Include macro extension plugin'
  author 'Taiki IKEGAME'
  description 'This plugin makes possible include wiki section.'
  version '0.0.3'
  url 'https://github.com/taikii/redmine_include_macro_extension'
  author_url 'https://github.com/taikii'

  Redmine::WikiFormatting::Macros.register do
    desc "Includes a wiki page. Examples:\n\n" +
        "{{include(Foo)}}\n" +
        "{{include(Foo, Bar)}} -- to include Bar section of Foo page\n" +
        "{{include(projectname:Foo)}} -- to include a page of a specific project wiki"
    macro :include do |obj, args|
      out = ''
      page = Wiki.find_page(args.first.to_s, :project => @project)
      raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
      @included_wiki_pages ||= []

      if args.size == 1
        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
        @included_wiki_pages << page.title
        out = textilizable(page.content, :text, :attachments => page.attachments, :headings => false)
        @included_wiki_pages.pop
      else
        secname = args[1].to_s
        index = 0
        case Setting.text_formatting
        when "textile"
          page.content.text.scan(/(?:\A|\r?\n\s*\r?\n)h\d+\.[ \t]+(.*?)(?:\r?\n\s*\r?\n|\z)/m).each.with_index(1) do |matched, i|
            if matched.first.gsub(/[\r\n]/, '') == secname
              index = i
              break
            end
          end
        when "markdown"
          page.content.text.scan(/(?:\A|\r?\n)#+ +(.*?)(?:\r?\n|\z)/).each.with_index(1) do |matched, i|
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

        if sectext
          raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title) || @included_wiki_pages.include?(page.title + ':' + secname)
          @included_wiki_pages << page.title + ':' + secname
          out = textilizable(sectext, :attachments => page.attachments, :headings => false)
          @included_wiki_pages.pop
        end
      end

      out
    end
  end
end
