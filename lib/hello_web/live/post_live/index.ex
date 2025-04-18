defmodule HelloWeb.PostLive.Index do
  use HelloWeb, :live_view

  alias Hello.TImeline
  alias Hello.TImeline.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, TImeline.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, TImeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({HelloWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = TImeline.get_post!(id)
    {:ok, _} = TImeline.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
