--# selene: allow(undefined_variable, incorrect_standard_library_use)

local os = require("os")

context("Utils:", function()
  local utils = require("sofa.utils")
  describe("apply_defaults", function()
    local base = {
      hello = "world",
      name = "bar",
      other = {
        this = "that",
      },
    }
    local defaults = {
      name = "foo",
      surname = "fuzz",
      other = {
        this = "other",
        another = true,
        yet_another = {
          yes = false,
        },
      },
    }
    local res = utils.apply_defaults(base, defaults)
    it("should preserve values in base that are missing in default", function()
      assert.are.equal("world", res.hello)
    end)
    it("should take over missing values from default", function()
      assert.are.equal("fuzz", res.surname)
    end)
    it("should support nested tables", function()
      local expected = {
        this = "that",
        another = true,
        yet_another = {
          yes = false,
        },
      }
      assert.are.same(expected, res.other)
    end)
  end)

  describe("expand_home", function()
    it("should not modify a path without home", function()
      local path = "/home/f4z3r/Documents/"
      assert.are.equal(path, utils.expand_home(path))
    end)
    it("should replace the home diretory of a user", function()
      local path = "~/Documents/"
      local home = os.getenv("HOME")
      assert.are.same(home .. "/Documents/", utils.expand_home(path))
    end)
    it("should not replace tildes elsewhere in the path", function()
      local path = "/home/f4z3r/test/~/Documents/"
      assert.are.equal(path, utils.expand_home(path))
    end)
  end)

  describe("build_env_string_from_params", function()
    it("should replace - with _ in the keys", function()
      local params = {
        ["this-is-a-key"] = "test",
      }
      local env = utils.build_env_string_from_params(params)
      assert.does.match("THIS_IS_A_KEY=", env, nil, true)
    end)

    it("wrap values in quotes to ensure correct handling", function()
      local params = {
        ["key"] = "value",
      }
      local env = utils.build_env_string_from_params(params)
      assert.does.match("^KEY='value'$", env)
    end)

    it("uses all values provided", function()
      local params = {
        ["key"] = "value",
        ["other"] = "test",
      }
      local env = utils.build_env_string_from_params(params)
      assert.does.match("KEY='value'", env)
      assert.does.match("OTHER='test'", env)
    end)

    it("should escape single quotes in values", function()
      local params = {
        ["key"] = "value with 'quotes'",
        ["key2"] = 'value with "quotes"',
      }
      local env = utils.build_env_string_from_params(params)
      assert.does.match("KEY='value with '\\''quotes'\\'''", env)
      assert.does.match("KEY2='value with \"quotes\"", env)
    end)
  end)
end)
