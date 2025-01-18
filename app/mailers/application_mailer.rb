# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "shrikaranks@gmail.com"
  layout "mailer"
end
