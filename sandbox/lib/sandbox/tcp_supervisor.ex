defmodule Sandbox.TcpSupervisor do
  require Logger

  def start_link(worker_pairs_count) do
    pid = Process.spawn(fn -> start(worker_pairs_count) end, [])
    {:ok, pid}
  end

  def start(worker_pairs_count) do
    worker_list = start_workers(worker_pairs_count * 2)
    ready_queue = :queue.from_list(worker_list)

    Process.register(self(), :tcp_supervisor)
    Logger.info("[TcpSupervisor] started with #{worker_pairs_count} worker pairs")

    loop(worker_list, ready_queue, :queue.new())
  end

  def start_workers(worker_count) do
    start_worker([], worker_count)
  end

  def start_worker(worker_list, count) when count == 0 do
    worker_list
  end

  def start_worker(worker_list, count) do
    pid = spawn_link(fn -> Sandbox.TcpWorker.start(self()) end)
    start_worker([pid | worker_list], count - 1)
  end

  def loop(worker_list, ready_queue, request_queue) do
    receive do
      {:forward_request, sender, recipent} ->
        Logger.info("[TcpSupervisor] handling request")
        if :queue.is_empty(ready_queue) do
          new_request_queue = :queue.in({sender, recipent}, request_queue)
          loop(worker_list, ready_queue, new_request_queue)
        else
          {{:value, worker1}, new_ready_queue1} = :queue.out(ready_queue)
          {{:value, worker2}, new_ready_queue2} = :queue.out(new_ready_queue1)
          send(worker1, {:connect, sender, recipent})
          send(worker2, {:connect, recipent, sender})
          Logger.info("[TcpSupervisor] request sent to worker")
          loop(worker_list, new_ready_queue2, request_queue)
        end

      {:done, worker} ->
        Logger.info("[TcpSupervisor] worker reported back")
        if :queue.is_empty(request_queue) do
          new_ready_queue = :queue.in(worker, ready_queue)
          loop(worker_list, new_ready_queue, request_queue)
        else
          {{:value, {sender, recipent}}, new_request_queue} = :queue.out(request_queue)
          send(worker, {:forward, sender, recipent})
          loop(worker_list, ready_queue, new_request_queue)
        end
    end
  end

  def forward_request(sender, recipent) do
    send(:tcp_supervisor, {:forward_request, sender, recipent})
  end

  def worker_done(worker) do
    send(:tcp_supervisor, worker)
  end
end
