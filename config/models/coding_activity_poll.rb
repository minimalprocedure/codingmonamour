# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################
require 'sequel'

class CodingActivityContextsPoll < Sequel::Model
  one_to_one :teacher_skills, :class => "CodingActivityTeacherSkillsPoll", :key => :context_id
  one_to_one :projects, :class => "CodingActivityProjectsPoll", :key => :context_id
  one_to_one :ratings, :class => "CodingActivityRatingsPoll", :key => :context_id
  one_to_one :futures, :class => "CodingActivityFuturesPoll", :key => :context_id
end

class CodingActivityTeacherSkillsPoll < Sequel::Model
  many_to_one :context, :class => "CodingActivityContextsPoll"
end

class CodingActivityProjectsPoll < Sequel::Model
  many_to_one :context, :class => "CodingActivityContextsPoll"
end

class CodingActivityRatingsPoll < Sequel::Model
  many_to_one :context, :class => "CodingActivityContextsPoll"
end

class CodingActivityFuturesPoll < Sequel::Model
  many_to_one :context, :class => "CodingActivityContextsPoll"
end

