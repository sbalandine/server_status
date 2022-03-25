shiny_user <- 's-balandine'
shiny_dir <- sprintf('/home/%s/r.shiny', shiny_user)
shiny_dir_cache <- file.path(shiny_dir, 'status', 'cache')

dir.create(shiny_dir_cache, showWarnings = FALSE)

setwd(shiny_dir_cache)

file <- 'logs.Rdata'

## try to load in R loga
tryCatch(load(file),
  warning = function(c) {return(NULL)}, #' warning on read of load loga',
  error = function(c) {return(NULL)},
  message = function(c) 'message'
)

## if the above fails then `logs` doesn't exist so let's set it to null
if (!exists('logs')) {
  logs <- NULL
}

I <- 0

repeat {
  system(sprintf('top -n 1 -b -u %s > top.log', shiny_user))
  log <- readLines('top.log')
  id <- grep('R *$', log)
  Names <- strsplit(gsub('^ +|%|\\+', '', log[7]), ' +')[[1]]
  if (length(id) > 0) {
    # 'top' loga frame;
    L <- strsplit(gsub('^ *', '', log[id]), ' +')
    log <- data.frame(matrix(unlist(L), ncol = 12, byrow = T))
    names(log) <- Names
    log <- data.frame(Time = Sys.time(), log[, -ncol(log)], usr = NA, app = NA)
    log$CPU <- as.numeric(as.character(log$CPU))
    log$MEM <- as.numeric(as.character(log$MEM))
    # Check if connection number changed;
    for (i in 1:length(log$PID)) {
      PID <- log$PID[i]
      system(paste('sudo netstat -p | grep', PID, '> netstat.log'))
      system(paste('sudo netstat -p | grep', PID, '>> netstat.log2'))
      system(paste('sudo lsof -p', PID, sprintf('| grep %s > lsof.log', shiny_dir)))
      netstat <- readLines('netstat.log')
      lsof <- readLines('lsof.log')
      log$usr[i] <- length(grep('ESTABLISHED', netstat) & grep('tcp', netstat))
      log$app[i] <- regmatches(lsof, regexec(sprintf('%s/(.*)', shiny_dir), lsof))[[1]][2]
    }
    if (!is.null(logs)) {
      log.a <- logs[which(logs$Time == max(logs$Time)), ]
      con.a <- log.a$usr[order(log.a$app)]
      con.b <- log$usr[order(log$app)]
      if (paste(con.a, collapse = '') == paste(con.b, collapse = '')) {
        changed <- FALSE
      } else {
        changed <- TRUE
      }
    } else {
      changed <- TRUE
    }
    # Keep only the lines containing important information to same storage space;
    if (any(log$CPU > 5) | any(log$MEM > 50) | changed) {
      logs <- rbind(logs, log)
      logs <- logs[which(logs$Time > (max(logs$Time) - 30 * 24 * 60 * 60)), ]
      save(logs, file = file)
    }
  }
  Sys.sleep(5)
  I <- I + 5
  if (I >= 60) {break}
}