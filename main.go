package main

import (
	"io"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/Ruscigno/docker-mt5/src/settings"
	"github.com/blendle/zapdriver"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/natefinch/lumberjack"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"

	"github.com/labstack/echo/v4"
)

type WriteSyncer struct {
	io.Writer
}

func (ws WriteSyncer) Sync() error {
	return nil
}

func connectsToPostgres(config *settings.Settings) (*sqlx.DB, error) {
	zap.L().Info("Trying to connect to the database")
	db, err := sqlx.Connect("postgres", config.DatabaseDSN)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(time.Minute)
	return db, nil
}

func SetupLogger(fileName string) *zap.Logger {
	// The bundled Config struct only supports the most common configuration
	// options. More complex needs, like splitting logs between multiple files
	// or writing to non-file outputs, require use of the zapcore package.
	//
	// In this example, imagine we're both sending our logs to Kafka and writing
	// them to the console. We'd like to encode the console output and the Kafka
	// topics differently, and we'd also like special treatment for
	// high-priority logs.

	// First, define our level-handling logic.
	highPriority := zap.LevelEnablerFunc(func(lvl zapcore.Level) bool {
		return lvl >= zapcore.ErrorLevel
	})
	lowPriority := zap.LevelEnablerFunc(func(lvl zapcore.Level) bool {
		return lvl < zapcore.ErrorLevel
	})

	// Assume that we have clients for two Kafka topics. The clients implement
	// zapcore.WriteSyncer and are safe for concurrent use. (If they only
	// implement io.Writer, we can use zapcore.AddSync to add a no-op Sync
	// method. If they're not safe for concurrent use, we can add a protecting
	// mutex with zapcore.Lock.)
	logFile := GetWriteSyncer(fileName)
	topicDebugging := zapcore.AddSync(logFile)
	topicErrors := zapcore.AddSync(logFile)

	// High-priority output should also go to standard error, and low-priority
	// output should also go to standard out.
	consoleDebugging := zapcore.Lock(os.Stdout)
	consoleErrors := zapcore.Lock(os.Stderr)

	var config zap.Config
	if "os.Getenv(utils.ConfigDebugLevel)" == "PROD" {
		config = zap.NewProductionConfig()
		config.EncoderConfig = zap.NewProductionEncoderConfig()
		config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	} else {
		config = zap.NewDevelopmentConfig()
		config.EncoderConfig = zap.NewDevelopmentEncoderConfig()
	}
	config.EncoderConfig.CallerKey = zapdriver.SourceLocation(runtime.Caller(0)).String
	configConsole := config
	configConsole.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder

	// Optimize the Kafka output for machine consumption and the console output
	// for human operators.
	kafkaEncoder := zapcore.NewJSONEncoder(config.EncoderConfig)
	consoleEncoder := zapcore.NewConsoleEncoder(configConsole.EncoderConfig)

	// Join the outputs, encoders, and level-handling functions into
	// zapcore.Cores, then tee the four cores together.
	core := zapcore.NewTee(
		zapcore.NewCore(kafkaEncoder, topicErrors, highPriority),
		zapcore.NewCore(consoleEncoder, consoleErrors, highPriority),
		zapcore.NewCore(kafkaEncoder, topicDebugging, lowPriority),
		zapcore.NewCore(consoleEncoder, consoleDebugging, lowPriority),
	)

	// From a zapcore.Core, it's easy to construct a Logger.
	logger := zap.New(core)
	return logger
}

func GetWriteSyncer(logName string) zapcore.WriteSyncer {
	var ioWriter = &lumberjack.Logger{
		Filename:   logName,
		MaxSize:    20, // MB
		MaxBackups: 5,  // number of backups
		MaxAge:     28, //days
		LocalTime:  true,
		Compress:   false, // disabled by default
	}
	var sw = WriteSyncer{
		ioWriter,
	}
	return sw
}

func main() {
	logger := SetupLogger("mt5-report-optimization-result-loader.log")
	defer logger.Sync()
	undo := zap.ReplaceGlobals(logger)
	defer undo()
	zap.L().Info("Starting service")
	config, err := settings.LoadSettings("settings.json")
	if err != nil {
		zap.L().Fatal(err.Error())
	}
	zap.L().Info("Settings loaded", zap.Any("settings", config))

	args := os.Args[1:] // get command line arguments excluding the program name

    if len(args) == 0 {
        fmt.Println("Usage: myprogram [command]")
        os.Exit(1)
    }

    switch args[0] {
		case "load":
												
	e := echo.New()
	// e.Use(echozap.ZapLogger(logger))
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})
	e.Logger.Fatal(e.Start(":3130"))
}
