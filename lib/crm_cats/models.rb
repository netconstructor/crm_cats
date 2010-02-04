# Make all core models act as taggable.
#----------------------------------------------------------------------------
[ Account, Campaign, Contact, Lead, Opportunity ].each do |klass|
  klass.class_eval do
    has_many :cattings, :dependent => :destroy
    has_many :cats, :through => :cattings, :uniq => true
    
    if respond_to?(:named_scope)
      named_scope :categorized_with, lambda{ |cat, options|
        self.find_options_for_find_categorized_with(cat, options)
      }
    end   
    
    def self.find_options_for_find_categorized_with(cat, options = {})

      return {} if cat.empty?
     
      conditions = []        
      conditions << "(cats.id = #{cat} or cats.parent_id = #{cat})"
      
      { :select => "DISTINCT #{table_name}.*",
        :joins => "LEFT OUTER JOIN cattings ON cattings.cattable_id = #{table_name}.#{primary_key} " +
                  "LEFT OUTER JOIN cats ON cats.id = cattings.cat_id",
        :conditions => conditions.join(" AND ")
      }
    end
    
  end
end