defmodule Hello.TImelineTest do
  use Hello.DataCase

  alias Hello.TImeline

  describe "posts" do
    alias Hello.TImeline.Post

    import Hello.TImelineFixtures

    @invalid_attrs %{body: nil, username: nil, likes_count: nil, reposts_count: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert TImeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert TImeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{body: "some body", username: "some username", likes_count: 42, reposts_count: 42}

      assert {:ok, %Post{} = post} = TImeline.create_post(valid_attrs)
      assert post.body == "some body"
      assert post.username == "some username"
      assert post.likes_count == 42
      assert post.reposts_count == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TImeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{body: "some updated body", username: "some updated username", likes_count: 43, reposts_count: 43}

      assert {:ok, %Post{} = post} = TImeline.update_post(post, update_attrs)
      assert post.body == "some updated body"
      assert post.username == "some updated username"
      assert post.likes_count == 43
      assert post.reposts_count == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = TImeline.update_post(post, @invalid_attrs)
      assert post == TImeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = TImeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> TImeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = TImeline.change_post(post)
    end
  end
end
