class PageContent < ActiveRecord::Base
  validates_length_of :content, maximum: 1500
  validates_length_of :html, maximum: 3000
  before_save :render_html
  after_initialize :init

  def init
    self.content ||= ''
  end

  def to_s
    String(html).html_safe
  end

  private

  def render_html
    self.html = markdown_render(content)
  end

  def markdown_render(content)
    html = renderer.render(content)

    doc = Nokogiri::HTML(html)

    doc.search("//p[contains(text(),'@video')]").each do |match|
      url = nil
      done = false
      match.children.each do |child|
        if done
          next
        end

        if 'a' == child.name
          url = child.attributes['href'].value
          match.replace video_template(url)
          done = true
          break
        end
      end
    end

    doc.to_s
  end

  def video_template(url)
%(<div class="col-xs-12">
  <div class="embed-responsive embed-responsive-16by9">
    <iframe class="embed-responsive-item" src="#{url}" frameborder="0" allowfullscreen></iframe>
  </div>
</div>)
  end

  def renderer
   Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(escape_html: true),
      autolink: true, tables: true,
    )
  end
end
