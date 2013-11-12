#########################################################################################
# 2013.8.16 geekerzp                                                                    #
# god 配置文件 检测goliath程序是否正常运行                                              #
#                                                                                       #
# 开启god监控（foreground）                       $ god -c config/listen.god -D         #
# 开启god监控（background）                       $ god -c config/listen.god            #
# 重新启动监控进程（必须在god监控开启的前提下）   $ god restart process_name            #
#########################################################################################

# 程序配置
API_ENV   = ENV['GOLIATH_ENV'] || 'production'
API_ROOT  = File.expand_path(File.dirname(__FILE__) + '/..')
God.pid_file_directory = "#{API_ROOT}/config"
PROCESS_NUM = 4   # 进程数

(1..PROCESS_NUM).each do |port|
  # 每一个watch开启一个进程
  God.watch do |w|

    w.dir = "#{API_ROOT}"                         # 程序根路径
    w.log = "#{API_ROOT}/log/#{API_ENV}-god.log"  # 日志
    port += 9000

    w.name      = "api-#{port}"                   # 进程名称
    w.interval  = 30.seconds                      # God检查时间

    w.start         = "cd #{API_ROOT} && ruby server.rb -sv -e production -l log/production.log -p #{port} -P #{API_ROOT}/tmp/pids/api.#{port}.pid -d"
    w.start_grace   = 10.seconds                  # 执行启动命令后缓冲时间
    w.stop          = "kill -QUIT `cat #{API_ROOT}/tmp/pids/api.#{port}.pid`"
    w.restart       = "#{w.stop} && #{w.start}"   # 默认行为
    w.restart_grace = 10.seconds                  # 执行重启命令后缓冲时间

    w.pid_file      = "#{API_ROOT}/tmp/pids/api.#{port}.pid"

    # Behaviors allow you execute additional commands around start/stop/restart commands.
    # In our case, if the process dies it will leave a PID file behind. The next time
    # command is issued, if will fail, complaining about the leftover PID file.
    # We'd like the PID file cleaned up before a start command is issued. The build-in behavior
    # clean_pid_file will do just that.
    w.behavior :clean_pid_file

    # Group conditions
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running  = false
      end
    end

    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above   = 150.megabytes
        c.times   = [3, 5]      # 3 out of 5 intervals
      end

      restart.condition(:cpu_usage) do |c|
        c.above   = 50.percent
        c.times   = 5
      end
    end

    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state      = [:start, :restart]
        c.times         = 5
        c.within        = 5.minutes
        c.transition    = :unmonitored
        c.retry_in      = 10.minutes
        c.retry_times   = 5
        c.retry_within  = 2.hours
      end
    end
  end
end
