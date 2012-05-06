module Gorillib ; end

# String inflections define new methods on the String class to transform names for different purposes.
#
#   "ScaleScore".underscore # => "scale_score"
#
# This doesn't define the full set of inflections -- only
#
# * camelize
# * snakeize
# * underscore
# * demodulize
#
module Gorillib::Inflector
  extend self

  def self.pluralizations
    @pluralizations ||= {}
  end

  def pluralize(str)
    Gorillib::Inflector.pluralizations.fetch(str){ "#{str}s" }
  end

  # The reverse of +pluralize+, returns the singular form of a word in a string.
  #
  # Examples:
  #   "posts".singularize            # => "post"
  #   # it's not very smart
  #   "octopi".singularize           # => "octopi"
  #   "bonus".singularize            # => "bonu"
  #   "boxes".singularize            # => "boxe"
  #   "CamelOctopi".singularize      # => "CamelOctopi"
  def singularize(str)
    Gorillib::Inflector.pluralizations.invert.fetch(str){ str.gsub(/s$/, '') }
  end

  # Capitalizes the first word and turns underscores into spaces and strips a
  # trailing "_id", if any. Like +titleize+, this is meant for creating pretty output.
  #
  # Examples:
  #   "employee_salary" # => "Employee salary"
  #   "author_id"       # => "Author"
  def humanize(lower_case_and_underscored_word)
    result = lower_case_and_underscored_word.to_s.dup
    result.gsub!(/_id$/, "")
    result.gsub(/(_)?([a-z\d]*)/i){ "#{ $1 && ' ' }#{ $2.downcase}" }.gsub(/^\w/){ $&.upcase }
  end

  # Capitalizes all the words and replaces some characters in the string to create
  # a nicer looking title. +titleize+ is meant for creating pretty output. It is not
  # used in the Rails internals.
  #
  # +titleize+ is also aliased as as +titlecase+.
  #
  # Examples:
  #   "man from the boondocks".titleize   # => "Man From The Boondocks"
  #   "x-men: the last stand".titleize    # => "X Men: The Last Stand"
  #   "TheManWithoutAPast".titleize       # => "The Man Without A Past"
  #   "raiders_of_the_lost_ark".titleize  # => "Raiders Of The Lost Ark"
  def titleize(word)
    humanize(underscore(word)).gsub(/\b('?[a-z])/){ $1.capitalize }
  end

  # Create the name of a table like Rails does for models to table names. This method
  # uses the +pluralize+ method on the last word in the string.
  #
  # Examples
  #   "RawScaledScorer".tableize # => "raw_scaled_scorers"
  #   "egg_and_ham".tableize     # => "egg_and_hams"
  #   "fancyCategory".tableize   # => "fancy_categories"
  def tableize(class_name)
    pluralize(underscore(class_name))
  end

  # Create a class name from a plural table name like Rails does for table names to models.
  # Note that this returns a string and not a Class. (To convert to an actual class
  # follow +classify+ with +constantize+.)
  #
  # Examples:
  #   "egg_and_hams".classify # => "EggAndHam"
  #   "posts".classify        # => "Post"
  #
  # Singular names are not handled correctly:
  #   "business".classify     # => "Busines"
  def classify(table_name)
    # strip out any leading schema name
    camelize(singularize(table_name.to_s.sub(/.*\./, '')))
  end

private

  # def uncountable_words #:doc
  #   %w( equipment information rice money species series fish )
  # end
  #
  # def plural_rules #:doc:
  #   [
  #     [/(x|ch|ss|sh)$/i,         '\1es'],      # search, switch, fix, box, process, address
  #     [/([^aeiouy]|qu)y$/i,      '\1ies'],     # query, ability, agency
  #     [/(p)erson$/i,             '\1eople'],   # person, salesperson
  #     [/(m)an$/i,                '\1en'],      # man, woman, spokesman
  #     [/(c)hild$/i,              '\1hildren'], # child
  #     [/s$/i,                    's'],         # no change (compatibility)
  #     [/$/,                      's']
  #   ]
  # end
  #
  # def singular_rules
  #   [
  #     [/(x|ch|ss|sh)es$/i,       '\1'],
  #     [/([^aeiouy]|qu)ies$/i,    '\1y'],
  #     [/(p)eople$/i,             '\1\2erson'],
  #     [/(m)en$/i,                '\1an'],
  #     [/(c)hildren$/i,           '\1\2hild'],
  #     [/s$/i,                    '']
  #   ]
  # end

  #   %w[
  #         equipment    equipment
  #         information  information
  #         rice         rice
  #         money        money
  #         species      species
  #         series       series
  #         fish         fish
  # ]

  # def uncountable_words #:doc
  #   %w( equipment information rice money species series fish )
  # end
  #
  # def plural_rules #:doc:
  #   [
  #     [/^(ox)$/i,                '\1\2en'],    # ox
  #     [/([m|l])ouse$/i,          '\1ice'],     # mouse, louse
  #     [/(matr|vert|ind)ix|ex$/i, '\1ices'],    # matrix, vertex, index
  #     [/(x|ch|ss|sh)$/i,         '\1es'],      # search, switch, fix, box, process, address
  #     [/([^aeiouy]|qu)ies$/i,    '\1y'],
  #     [/([^aeiouy]|qu)y$/i,      '\1ies'],     # query, ability, agency
  #     [/(hive)$/i,               '\1s'],       # archive, hive
  #     [/(?:([^f])fe|([lr])f)$/i, '\1\2ves'],   # half, safe, wife
  #     [/sis$/i,                  'ses'],       # basis, diagnosis
  #     [/([ti])um$/i,             '\1a'],       # datum, medium
  #     [/(p)erson$/i,             '\1eople'],   # person, salesperson
  #     [/(m)an$/i,                '\1en'],      # man, woman, spokesman
  #     [/(c)hild$/i,              '\1hildren'], # child
  #     [/(buffal|tomat)o$/i,      '\1\2oes'],   # buffalo, tomato
  #     [/(bu)s$/i,                '\1\2ses'],   # bus
  #     [/(alias)/i,               '\1es'],      # alias
  #     [/(octop|vir)us$/i,        '\1i'],       # octopus, virus - virus has no defined plural (according to Latin/dictionary.com), but viri is better than viruses/viruss
  #     [/(ax|cri|test)is$/i,      '\1es'],      # axis, crisis
  #     [/s$/i,                    's'],         # no change (compatibility)
  #     [/$/,                      's']
  #   ]
  # end
  #
  # def singular_rules
  #   [
  #     [/(matr)ices$/i,           '\1ix'],
  #     [/(vert|ind)ices$/i,       '\1ex'],
  #     [/^(ox)en/i,               '\1'],
  #     [/(alias)es$/i,            '\1'],
  #     [/([octop|vir])i$/i,       '\1us'],
  #     [/(cris|ax|test)es$/i,     '\1is'],
  #     [/(shoe)s$/i,              '\1'],
  #     [/(o)es$/i,                '\1'],
  #     [/(bus)es$/i,              '\1'],
  #     [/([m|l])ice$/i,           '\1ouse'],
  #     [/(x|ch|ss|sh)es$/i,       '\1'],
  #     [/(m)ovies$/i,             '\1\2ovie'],
  #     [/(s)eries$/i,             '\1\2eries'],
  #     [/([^aeiouy]|qu)ies$/i,    '\1y'],
  #     [/([lr])ves$/i,            '\1f'],
  #     [/(tive)s$/i,              '\1'],
  #     [/(hive)s$/i,              '\1'],
  #     [/([^f])ves$/i,            '\1fe'],
  #     [/([ti])a$/i,              '\1um'],
  #     [/(p)eople$/i,             '\1\2erson'],
  #     [/(m)en$/i,                '\1an'],
  #     [/(s)tatus$/i,             '\1\2tatus'],
  #     [/(c)hildren$/i,           '\1\2hild'],
  #     [/(n)ews$/i,               '\1\2ews'],
  #     [/s$/i,                    '']
  #   ]
  # end

  # inflect.plural(/$/, 's')
  # inflect.plural(/s$/i, 's')
  # inflect.plural(/^(ax|test)is$/i, '\1es')
  # inflect.plural(/(octop|vir)us$/i, '\1i')
  # inflect.plural(/(octop|vir)i$/i, '\1i')
  # inflect.plural(/(alias|status)$/i, '\1es')
  # inflect.plural(/(bu)s$/i, '\1ses')
  # inflect.plural(/(buffal|tomat)o$/i, '\1oes')
  # inflect.plural(/([ti])um$/i, '\1a')
  # inflect.plural(/([ti])a$/i, '\1a')
  # inflect.plural(/sis$/i, 'ses')
  # inflect.plural(/(?:([^f])fe|([lr])f)$/i, '\1\2ves')
  # inflect.plural(/(hive)$/i, '\1s')
  # inflect.plural(/([^aeiouy]|qu)y$/i, '\1ies')
  # inflect.plural(/(x|ch|ss|sh)$/i, '\1es')
  # inflect.plural(/(matr|vert|ind)(?:ix|ex)$/i, '\1ices')
  # inflect.plural(/(m|l)ouse$/i, '\1ice')
  # inflect.plural(/(m|l)ice$/i, '\1ice')
  # inflect.plural(/^(ox)$/i, '\1en')
  # inflect.plural(/^(oxen)$/i, '\1')
  # inflect.plural(/(quiz)$/i, '\1zes')

  # inflect.singular(/s$/i, '')
  # inflect.singular(/(ss)$/i, '\1')
  # inflect.singular(/(n)ews$/i, '\1ews')
  # inflect.singular(/([ti])a$/i, '\1um')
  # inflect.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$/i, '\1\2sis')
  # inflect.singular(/(^analy)(sis|ses)$/i, '\1sis')
  # inflect.singular(/([^f])ves$/i, '\1fe')
  # inflect.singular(/(hive)s$/i, '\1')
  # inflect.singular(/(tive)s$/i, '\1')
  # inflect.singular(/([lr])ves$/i, '\1f')
  # inflect.singular(/([^aeiouy]|qu)ies$/i, '\1y')
  # inflect.singular(/(s)eries$/i, '\1eries')
  # inflect.singular(/(m)ovies$/i, '\1ovie')
  # inflect.singular(/(x|ch|ss|sh)es$/i, '\1')
  # inflect.singular(/(m|l)ice$/i, '\1ouse')
  # inflect.singular(/(bus)(es)?$/i, '\1')
  # inflect.singular(/(o)es$/i, '\1')
  # inflect.singular(/(shoe)s$/i, '\1')
  # inflect.singular(/(cris|test)(is|es)$/i, '\1is')
  # inflect.singular(/^(a)x[ie]s$/i, '\1xis')
  # inflect.singular(/(octop|vir)(us|i)$/i, '\1us')
  # inflect.singular(/(alias|status)(es)?$/i, '\1')
  # inflect.singular(/^(ox)en/i, '\1')
  # inflect.singular(/(vert|ind)ices$/i, '\1ex')
  # inflect.singular(/(matr)ices$/i, '\1ix')
  # inflect.singular(/(quiz)zes$/i, '\1')
  # inflect.singular(/(database)s$/i, '\1')
  #
  # inflect.irregular('person', 'people')
  # inflect.irregular('man', 'men')
  # inflect.irregular('child', 'children')
  # inflect.irregular('sex', 'sexes')
  # inflect.irregular('move', 'moves')
  # inflect.irregular('cow', 'kine')
  # inflect.irregular('zombie', 'zombies')
  #
  # inflect.uncountable(%w(equipment information rice money species series fish sheep jeans))

public

  # def pluralize(word)
  #   result = word.dup
  #   plural_rules.each do |(rule, replacement)|
  #     break if result.gsub!(rule, replacement)
  #   end
  #   return result
  # end
  #
  # def singularize(word)
  #   result = word.dup
  #   singular_rules.each do |(rule, replacement)|
  #     break if result.gsub!(rule, replacement)
  #   end
  #   return result
  # end

end
