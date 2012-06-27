# -*- coding: utf-8 -*-
module Gorillib
  module Utils
    module EdgeCases
      # Thanks http://www.geertvanderploeg.com/unicode-gen/ !
      # For more fun, see http://www.tamasoft.co.jp/en/general-info/unicode.html
      STRINGS = {
        :unicode_smileys => '٩(-̮̮̃-̃)۶ ٩(●̮̮̃•̃)۶ ٩(͡๏̯͡๏)۶ ٩(-̮̮̃•̃).',
        :internationalization => 'Iｎｔèｒｎａｔｉòｎãｌïｚãｔíｏｎ',
        :html_unsafe => 'Testing «Mònkêy Sí Monkè Dü»: 1<2 & 4+1>3, now 20% off!',

        :eastern_arabic_digits => '٠١٢٣٤٥٦٧٨٩',
        :bengali_digits        => '০১২৩৪৫৬৭৮৯',
      }

    end
  end
end
