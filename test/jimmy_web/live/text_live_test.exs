defmodule JimmyWeb.TextLiveTest do
  use JimmyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Jimmy.RobotFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_text(_) do
    text = text_fixture()
    %{text: text}
  end

  describe "Index" do
    setup [:create_text]

    test "lists all texts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.text_index_path(conn, :index))

      assert html =~ "Listing Texts"
    end

    test "saves new text", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.text_index_path(conn, :index))

      assert index_live |> element("a", "New Text") |> render_click() =~
               "New Text"

      assert_patch(index_live, Routes.text_index_path(conn, :new))

      assert index_live
             |> form("#text-form", text: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text-form", text: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_index_path(conn, :index))

      assert html =~ "Text created successfully"
    end

    test "updates text in listing", %{conn: conn, text: text} do
      {:ok, index_live, _html} = live(conn, Routes.text_index_path(conn, :index))

      assert index_live |> element("#text-#{text.id} a", "Edit") |> render_click() =~
               "Edit Text"

      assert_patch(index_live, Routes.text_index_path(conn, :edit, text))

      assert index_live
             |> form("#text-form", text: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text-form", text: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_index_path(conn, :index))

      assert html =~ "Text updated successfully"
    end

    test "deletes text in listing", %{conn: conn, text: text} do
      {:ok, index_live, _html} = live(conn, Routes.text_index_path(conn, :index))

      assert index_live |> element("#text-#{text.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#text-#{text.id}")
    end
  end

  describe "Show" do
    setup [:create_text]

    test "displays text", %{conn: conn, text: text} do
      {:ok, _show_live, html} = live(conn, Routes.text_show_path(conn, :show, text))

      assert html =~ "Show Text"
    end

    test "updates text within modal", %{conn: conn, text: text} do
      {:ok, show_live, _html} = live(conn, Routes.text_show_path(conn, :show, text))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Text"

      assert_patch(show_live, Routes.text_show_path(conn, :edit, text))

      assert show_live
             |> form("#text-form", text: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#text-form", text: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_show_path(conn, :show, text))

      assert html =~ "Text updated successfully"
    end
  end
end
