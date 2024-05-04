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
end)
