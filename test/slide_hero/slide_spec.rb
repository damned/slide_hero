require 'minitest_helper'

module SlideHero
  describe Slide do
    describe "initialization" do
      it "is initialized with a title" do
        slide = Slide.new("Badgers learn knitting")
        slide.headline.must_equal "Badgers learn knitting"
      end

      it "can be initialized with no title" do
        slide = Slide.new
        slide.headline.must_equal nil
      end

      it "can take an optional side directive" do
        slide = Slide.new("Badgers learn knitting", headline_size: :large)
        slide.headline_size.must_equal :large

        slide = Slide.new("Snacks lead to revolution in food care", headline_size: :medium)
        slide.headline_size.must_equal :medium
      end

      it "can take a background color" do
        slide = Slide.new("Badgers learn knitting", background_color: 'blue')
        slide.background_color.must_equal 'blue'
      end
    end

    describe "compilation" do
      it "outputs object to html" do
        slide = Slide.new("To Markup!")
        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>To Markup!</h2> " +
          "</section>"
      end

      it "respects headline size" do
        slide = Slide.new("To Markup!", headline_size: :medium)
        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>To Markup!</h2>" +
          "</section>"
      end

      it "takes transitions" do
        slide = Slide.new("transitions", transition: :zoom) do
        end
        assert_dom_match slide.compile, '<section data-transition="zoom">' +
          '<h2>transitions</h2>' +
          '</section>'
      end

      it "takes a background_color" do
        slide = Slide.new("background_color", background_color: 'blue') do
        end
        assert_dom_match slide.compile, '<section data-transition="default" ' +
         'data-background="blue">' +
          '<h2>background_color</h2>' +
          '</section>'
      end
    end

    describe "#point syntax" do
      it "embeds text in p tags by default" do
        slide = Slide.new "Embedding" do
          point "I'm embedded!"
        end

        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Embedding</h2>" +
          "<p>I'm embedded!</p>" +
          "</section>"
      end

      it "embeds raw html" do
        slide = Slide.new "Embedding" do
          point "<small>I'm embedded!</small>"
        end

        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Embedding</h2>" + 
          "<p><small>I'm embedded!</small></p>" +
          "</section>"
      end

      it "embeds multiple points" do
        slide = Slide.new "Embedding" do
          point "I'm embedded!"
          point "Me too!"
        end

        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Embedding</h2>" + 
          "<p>I'm embedded!</p>" +
          "<p>Me too!</p>" +
          "</section>"
      end

      it "animates points" do
        slide = Slide.new "Animation" do
          point "I'm animated!", animation: true
        end

        assert_dom_match slide.compile, "<section data-transition=\"default\">"+
          "<h2>Animation</h2>" + 
          "<p class=\"fragment \">I'm animated!</p>" +
          "</section>"

      end
    end

    describe "#list" do
      it "creates bullets from a block" do
        slide = Slide.new "Lists" do
          list do
            point "Bullet Points"
            point "Another Point"
          end
        end
        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Lists</h2>" +
          "<ul>" +
          "<li>Bullet Points</li>" +
          "<li>Another Point</li>" +
          "</ul>" +
          "</section>"
      end

      it "creates ordered lists from a block" do
        slide = Slide.new "Lists" do
          list(:ordered) do
            point "Ordered!"
            point "Also ordered!"
          end
        end
        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Lists</h2>" +
          "<ol>" +
          "<li>Ordered!</li>" +
          "<li>Also ordered!</li>" +
          "</ol>" +
          "</section>"
      end
    end
    describe "#code" do
      it "embeds code in a slide" do
        slide = Slide.new "Code" do
          code(:ruby, File.join(Dir.pwd,"test","fixtures")) do
            "testclass.rb"
          end
        end

        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Code</h2>" +
          "<pre><code data-trim class=\"ruby\">
  class Working
  def some_method
    \"woot!\"
  end
end

</code></pre></section>"
      end
    end

    describe "#note" do
      it "returns a formatted note" do
        slide = Slide.new "Note" do
          note "Don't forget to bring a towel"
        end
        assert_dom_match slide.compile, "<section data-transition=\"default\">" +
          "<h2>Note</h2>" +
          "<aside class=\"notes\">Don't forget to bring a towel</aside>" +
          "</section>"
      end
    end

    describe "#image" do
      it "returns a formatted Image" do
        slide = Slide.new "Image" do
          image("cornify.gif", "Unicorn", width: 280, height: 326)
        end

        slide.compile.must_include %{<img width="280" height="326" src="images/cornify.gif" alt="Unicorn">}
      end
    end

    describe "#media" do
      it "returns a formatted media element" do
        slide = Slide.new "Video" do
          media "video.mp4", type: :video
        end

        slide.compile.must_include %{<video data-autoplay src="video/video.mp4"></video>}
      end
    end
  end
end
