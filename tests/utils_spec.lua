--# selene: allow(undefined_variable, incorrect_standard_library_use)

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
end)
