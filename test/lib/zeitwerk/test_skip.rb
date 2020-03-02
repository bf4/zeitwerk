require "test_helper"
require "set"

class TestSkip < LoaderTest
  test "skipped directories are ignored as namespaces" do
    files = [["foo/bar/x.rb", "Foo::X = true"]]
    with_files(files) do
      loader.push_dir(".")
      loader.skip("foo/bar")
      loader.setup

      assert Foo::X
    end
  end

  test "accepts several arguments" do
    files = [
      ["foo/bar/x.rb", "Foo::X = true"],
      ["zoo/bar/x.rb", "Zoo::X = true"]
    ]
    with_files(files) do
      loader.push_dir(".")
      loader.skip("foo/bar", "zoo/bar")
      loader.setup

      assert Foo::X
      assert Zoo::X
    end
  end

  test "accepts an array" do
    files = [
      ["foo/bar/x.rb", "Foo::X = true"],
      ["zoo/bar/x.rb", "Zoo::X = true"]
    ]
    with_files(files) do
      loader.push_dir(".")
      loader.skip(["foo/bar", "zoo/bar"])
      loader.setup

      assert Foo::X
      assert Zoo::X
    end
  end

  test "supports glob patterns" do
    files = [
      ["foo/bar/x.rb", "Foo::X = true"],
      ["zoo/bar/x.rb", "Zoo::X = true"]
    ]
    with_files(files) do
      loader.push_dir(".")
      loader.skip("*/bar")
      loader.setup

      assert Foo::X
      assert Zoo::X
    end
  end

  test "skips are recomputed on reload" do
    files = [["foo/bar/x.rb", "Foo::X = true"]]
    with_files(files) do
      loader.push_dir(".")
      loader.skip("*/bar")
      loader.setup

      assert Foo::X
      assert_raises(NameError) { Zoo::X }

      FileUtils.mkdir_p("zoo/bar")
      File.write("zoo/bar/x.rb", "Zoo::X = true")

      loader.reload

      assert Foo::X
      assert Zoo::X
    end
  end

  test "skips are honored when eager loading" do
    $skip_honored_when_eager_loading = false
    files = [["foo/bar/x.rb", "Foo::X = true; $skip_honored_when_eager_loading = true"]]
    with_files(files) do
      loader.push_dir(".")
      loader.skip("foo/bar")
      loader.setup
      loader.eager_load

      assert $skip_honored_when_eager_loading
    end
  end
end
