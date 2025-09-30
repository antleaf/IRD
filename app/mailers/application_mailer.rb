class ApplicationMailer < ActionMailer::Base
  default from: "IRD <#{ENV['SMTP_USERNAME']}>"
  layout "mailer"
end
