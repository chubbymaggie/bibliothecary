module Bibliothecary
  module Parsers
    class SwiftPM
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^Package\.swift$/i => {
            kind: 'manifest',
            parser: :parse_package_swift
          }
        }
      end

      def self.parse_package_swift(manifest)
        response = Typhoeus.post("http://swift.libraries.io/to-json", body: manifest)
        json = JSON.parse(response.body)
        json["dependencies"].map do |dependency|
          name = dependency['url'].gsub(/^https?:\/\//, '').gsub(/\.git$/,'')
          version = "#{dependency['version']['lowerBound']} - #{dependency['version']['upperBound']}"
          {
            name: name,
            version: version,
            type: 'runtime'
          }
        end
      end
    end
  end
end
