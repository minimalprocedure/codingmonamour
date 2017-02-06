# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module Helpers

  require 'yaml'



  def m_values_or_default(key, options = {})
    options.reverse_merge! ({
      :def => '',
      :scope => :all
    })
    def m_value(context, key, default)
      begin
        result = @metadatas[context.to_s][key.to_s]      
        result.nil? ? default : result
      rescue
        default
      end
    end
    if options[:scope] == :all
      [m_value(:application, key, options[:def]), m_value(:document, key, options[:def])]
    else
      [m_value(options[:scope], key, options[:def]), options[:def]]
    end
  end

  def m_string(key, options = {})
    options.reverse_merge! ({
      :sep => ' ',
      :scope => :all
    })
    val1, val2 = m_values_or_default(key, :def => '', :scope => options[:scope])
    "#{val1}#{val1.empty? ? '' : options[:sep].to_s}#{val2}"
  end

  def m_date(key, options = {})
    options.reverse_merge! ({
      :sep => ' ',
      :scope => :all,
      :format => '%d-%m-%Y'
    })
    val1, val2 = m_values_or_default(key, :def => nil, :scope => options[:scope])
    val1 = val1.nil? ? '' : val1.strftime(options[:format])
    val2 = val2.nil? ? '' : val2.strftime(options[:format])
    "#{val1}#{val1.empty? ? '' : options[:sep].to_s}#{val2}"
  end

  def m_array(key, options = {})
    options.reverse_merge! ({
      :scope => :all,
      :sorted => true
    })
    val1, val2 = m_values_or_default(key, :def => [], :scope => options[:scope])   
    if options[:sorted]
      val1.size >= val2.size ? [val1, val2] : [val2, val1]
    else
      [val1, val2]
    end
  end

  def m_metas(options = {})
    options.reverse_merge! ({
      :scope => :all
    })
    list1, list2 = m_array(:metas, :scope => options[:scope])    
    list1.concat(list2)    
    (list1.reduce(list2) { |acc, v|
       kv = v.split('=')
       acc << %(<meta name="#{ kv[0].to_s.strip }" content="#{kv[1].to_s.strip }">)
       acc
      }).join('\n')
  end

  def m_keywords
    val1 = (m_value(:application, :keywords, '').to_s.split(',')).map { |k| k.strip }
    val2 = (m_value(:document, :keywords, '').to_s.split(',')).map { |k| k.strip }
    list1, list2 = val1.size >= val2.size ? [val1, val2] : [val2, val1]
    (list1.reduce(list2) { |acc, k|
       acc << k unless list2.include?(k)
       acc
      }).join(',')
  end

  def find_docs_and_dirs(base, ext = :markdown)
    ignore = ['views', 'errors','layouts','stylesheets','\.disabled$']
    rev_root = File.join(DOC_FOLDER, base)
    
    docs = Dir[File.join(rev_root, "*.#{ ext.to_s }")].natural_sort
    dirs = (Dir[File.join(rev_root, '*')].map { |d|
              rev_root = File.join(DOC_FOLDER, '/')
              d.gsub(rev_root, '') if (File.directory?(d) && !ignore.any? { |i| d.match(Regexp.new(i))})
      }).compact.natural_sort
    [docs, dirs]
  end

  def top_menu(base, ext = :markdown)
    docs, dirs = find_docs_and_dirs(base, ext)
    links = docs.reduce([]) { |acc, f|
      path = f.scan(%r{\/.*\.(.*)\..*})[0][0]
      index = @metadatas.fetch2(['application', 'home', 'document'], 'index')
      name = path.to_s.gsub(/\W|_/, ' ').squeeze(' ')
      acc << %(<li><a class="nav-button doc-link" href="#{File.join(base, path.to_s)}">#{name}</a></li>) unless path.match(%r{\/#{index}})
      acc.compact
    }
    home = @metadatas.fetch2(['application', 'home', 'name'], 'Home')
    postlinks = dirs.reduce([]) { |acc, l|
      acc << %(<li><a class="nav-button dir-link" href="/#{l}">#{File.basename(l)}</a></li>)
    }
    postlinks << @metadatas.fetch2(['document', 'links'], []).reduce([]) { |acc, l|
      part = l.split('=')
      acc << %(<li><a class="nav-button doc-extra-link" href="#{part[1]}">#{part[0]}</a></li>)
    }
    postlinks.flatten!
    %(<ul class="nav navbar-nav top-navbar-links"><li><a class="nav-button home-link" href="/">#{home}</a></li>#{ links.join("\n") }#{ postlinks.join("\n") }</ul>)
  end

end
