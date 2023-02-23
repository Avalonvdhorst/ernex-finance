require "open-uri"
require "nokogiri"

class FundsController < ApplicationController
  def scrape
    Fund.destroy_all
    extensions = ["0P00000JGA.F", "0P0001DFPM.F", "0P00015OFP.F", "IEGB.F", "XUMB.F"]
    extensions.each do |extension|
      url = "https://finance.yahoo.com/quote/#{extension}"
      html_file = URI.open(
        url,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
      ).read
      html_doc = Nokogiri::HTML.parse(html_file)

      results = html_doc.search("fin-streamer")
      name = html_doc.search("h1").text.strip
      price_elements = results.select do |element|
        element.attribute('data-field').value == "regularMarketPrice"
      end
      price = price_elements.last.text.strip
      @fund = Fund.new(name: name, price: price)
      @fund.save
    end
  end

  def index
    scrape
    @funds = Fund.all
  end
end
