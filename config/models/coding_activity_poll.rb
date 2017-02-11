# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################
require 'sequel'

class CodingActivityContextsPoll < Sequel::Model(Sequel::Model.db_polls)
  one_to_one :teacher_skills, :class => :CodingActivityTeacherSkillsPoll, :key => :context_id
  one_to_one :projects, :class => :CodingActivityProjectsPoll, :key => :context_id
  one_to_one :ratings, :class => :CodingActivityRatingsPoll, :key => :context_id
  one_to_one :futures, :class => :CodingActivityFuturesPoll, :key => :context_id

  def validate
    super
    validates_presence :province, :message => "Provincia mancante."
    validates_presence :school, :message => "Scuola mancante."
    validates_presence :classroom, :message => "Classe mancante."
    validates_presence :average_age, :message => "Età media mancante."
    validates_presence :males, :message => "Numero partecipanti maschi mancante."
    validates_presence :females, :message => "Numero partecipanti femmina mancante."
    validates_presence :date_begin, :message => "Data di inizio mancante."
    validates_presence :date_end, :message => "Data di termine mancante."
  end

end

class CodingActivityTeacherSkillsPoll < Sequel::Model(Sequel::Model.db_polls)
  many_to_one :context, :class => :CodingActivityContextsPoll

  def validate
    super
    validates_presence :age, :message => "Età insegnante mancante."
    validates_presence :role, :message => "Ruolo insegnante mancante."
    validates_presence :knowledge, :message => "Conoscenze mancanti."
    validates_presence :training, :message => "Formazione mancante."
  end

end

class CodingActivityProjectsPoll < Sequel::Model(Sequel::Model.db_polls)
  many_to_one :context, :class => :CodingActivityContextsPoll

  def validate
    super
    validates_presence :goals, :message => "Obiettivo mancante."
    validates_presence :estimated_time_in_days, :message => "Tempo previsto mancante."
    validates_presence :date_begin, :message => "Data di inizio mancante."
    validates_presence :date_end, :message => "Data di termine mancante."
    validates_presence :activity, :message => "Attività proposte mancanti."
    validates_presence :environments, :message => "Ambienti utilizzati mancanti."
  end
end

class CodingActivityRatingsPoll < Sequel::Model(Sequel::Model.db_polls)
  many_to_one :context, :class => :CodingActivityContextsPoll

  def validate
    super
    validates_presence :goals, :message => "Obiettivo mancante."
  end
end

class CodingActivityFuturesPoll < Sequel::Model(Sequel::Model.db_polls)
  many_to_one :context, :class => :CodingActivityContextsPoll
end
