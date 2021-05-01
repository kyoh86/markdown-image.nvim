local imgup = require('imgup')
local not_found = nil

describe("get_image_url", function()
  it("link1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](link)$')
    assert.is_nil(imgup.get_image_url())
  end)

  it("link2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](https://example.com/link)$')
    assert.is_nil(imgup.get_image_url())
  end)

  describe("img1", function()
    vim.cmd[[edit! ./spec/sample.md]]

    vim.fn.search('^![](image) foo$')
    it("match on head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(4, scol)
      assert.equal(9, ecol)
    end)

    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(4, scol)
      assert.equal(9, ecol)
    end)

    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  describe("img2", function()
    vim.cmd[[edit! ./spec/sample.md]]

    vim.fn.search('^![](image_with_width =3x) foo$')
    it("match on head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_width', path)
      assert.equal(4, scol)
      assert.equal(20, ecol)
    end)

    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_width', path)
      assert.equal(4, scol)
      assert.equal(20, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  it("img3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^![](image_with_size =3x6) foo$')
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_size', path)
      assert.equal(4, scol)
      assert.equal(19, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_size', path)
      assert.equal(4, scol)
      assert.equal(19, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image) foo\\](link)$')
    assert.is_nil(imgup.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(5, scol)
      assert.equal(10, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(5, scol)
      assert.equal(10, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_width =3x) foo\\](link)$')
    assert.is_nil(imgup.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_width', path)
      assert.equal(5, scol)
      assert.equal(21, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_width', path)
      assert.equal(5, scol)
      assert.equal(21, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_size =3x6) foo\\](link)$')
    assert.is_nil(imgup.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_size', path)
      assert.equal(5, scol)
      assert.equal(20, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image_with_size', path)
      assert.equal(5, scol)
      assert.equal(20, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_twice", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^!\\[\\](image) !\\[\\](image2)$')
    it("match on left-head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(4, scol)
      assert.equal(9, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on left-tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image', path)
      assert.equal(4, scol)
      assert.equal(9, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on left-end-paren')
    vim.cmd[[normal! l]]
    assert.is_nil(imgup.get_image_url(), 'not match on interlude')
    vim.cmd[[normal! f!]]
    it("match on right-head", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image2', path)
      assert.equal(15, scol)
      assert.equal(21, ecol)
    end)
    vim.cmd[[normal! t)]]
    it("match on right-tail", function()
      local path, scol, ecol, _ = imgup.get_image_url()
      assert.equal('image2', path)
      assert.equal(15, scol)
      assert.equal(21, ecol)
    end)
    vim.cmd[[normal! f)]]
    assert.is_nil(imgup.get_image_url(), 'not match on right-end-paren')
  end)
end)
