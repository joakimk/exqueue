defmodule Toniq.Worker do
  defmacro __using__(opts \\ []) do
    known_options = [:max_concurrency]

    unknown_option = Enum.find(opts, fn ({k, _v}) -> !Enum.member?(known_options, k) end)

    if unknown_option do
      {k, _v} = unknown_option
      raise "Unknown option #{inspect(k)}. Known options are #{inspect(known_options)}"
    end

    quote do
      require Logger

      # Delegate to perform without arguments when arguments are [],
      # you can define a perform with an argument to override this.
      def perform([]) do
        perform()
      end

      def handle_error(job, error, stack) do
        log_error(job, error, stack)
      end

      def max_concurrency do
        unquote(opts[:max_concurrency] || :unlimited)
      end

      defp log_error(job, error, stack) do
        stacktrace = Exception.format_stacktrace(stack)
        job_details = "##{job.id}: #{inspect(job.worker)}.perform(#{inspect(job.arguments)})"

        "Job #{job_details} failed with error: #{inspect(error)}\n\n#{stacktrace}"
        |> String.trim
        |> Logger.error
      end

      defoverridable [perform: 1, handle_error: 3]
    end
  end
end
