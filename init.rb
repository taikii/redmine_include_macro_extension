Redmine::Plugin.register :redmine_include_macro_extension do
 name 'Include macro extension plugin'
 author 'Taiki I'
 description 'This plugin makes possible include wiki section.'
 version '0.0.1'
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
        sectext = nil

        page.content.text.scan(/h\d+\. (.*)?\r\n\r\n/).each.with_index(1) do |matched, i|
          if matched.first.gsub(/\R/, '') == secname
            sectext, hash = Redmine::WikiFormatting.formatter.new(page.content.text).get_section(i)
            break
          end
        end

        if sectext
          raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title) || @included_wiki_pages.include?(page.title + '#' + secname)
          @included_wiki_pages << page.title + '#' + secname
          out = textilizable(sectext, :attachments => page.attachments, :headings => false)
          @included_wiki_pages.pop
        end
      end
      
      out
    end
 end
end

