module Sentry
  module Handler
    autoload :Base,    'sentry/handler/base'
    autoload :Generic, 'sentry/handler/generic'
    autoload :Mongrel, 'sentry/handler/mongrel'

    @handlerClasses = {
      :snapshot => Sentry::Handler::Generic,
      :restart_mongrel => Sentry::Handler::Mongrel,
      :notify_support => Sentry::Handler::Generic
    }
    class << self
      def getHandler(task_id,platform,process_type,condition,request,log)
        cls = @handlerClasses.fetch([task_id.to_s,process_type.to_s,platform.to_s].join("_").to_sym,nil) ||
	      @handlerClasses.fetch([task_id.to_s,process_type.to_s].join("_").to_sym,nil) ||
	      @handlerClasses.fetch(task_id.to_sym,nil) 
        return nil unless cls
	return cls.new(request,log)
      end
    end
  end
end
