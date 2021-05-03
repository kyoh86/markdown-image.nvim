local mdimg = require('markdown-image')
local not_found = nil

describe("get_image_url", function()
  it("link1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](link)$')
    assert.equal('', mdimg.get_image_url())
  end)

  it("link2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](https://example.com/link)$')
    assert.equal('', mdimg.get_image_url())
  end)

  describe("img1", function()
    vim.cmd[[edit! ./spec/sample.md]]

    vim.fn.search('^![](image) foo$')
    it("match on head", function()
      assert.equal('image', mdimg.get_image_url())
    end)

    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image', mdimg.get_image_url())
    end)

    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  describe("img2", function()
    vim.cmd[[edit! ./spec/sample.md]]

    vim.fn.search('^![](image_with_width =3x) foo$')
    it("match on head", function()
      assert.equal('image_with_width', mdimg.get_image_url())
    end)

    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image_with_width', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  it("img3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^![](image_with_size =3x6) foo$')
    it("match on tail", function()
      assert.equal('image_with_size', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image_with_size', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image) foo\\](link)$')
    assert.equal('', mdimg.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      assert.equal('image', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_width =3x) foo\\](link)$')
    assert.equal('', mdimg.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      assert.equal('image_with_width', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image_with_width', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_size =3x6) foo\\](link)$')
    assert.equal('', mdimg.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    it("match on head", function()
      assert.equal('image_with_size', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on tail", function()
      assert.equal('image_with_size', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on end paren')
  end)

  it("img_twice", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^!\\[\\](image) !\\[\\](image2)$')
    it("match on left-head", function()
      assert.equal('image', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on left-tail", function()
      assert.equal('image', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on left-end-paren')
    vim.cmd[[normal! l]]
    assert.equal('', mdimg.get_image_url(), 'not match on interlude')
    vim.cmd[[normal! f!]]
    it("match on right-head", function()
      assert.equal('image2', mdimg.get_image_url())
    end)
    vim.cmd[[normal! t)]]
    it("match on right-tail", function()
      assert.equal('image2', mdimg.get_image_url())
    end)
    vim.cmd[[normal! f)]]
    assert.equal('', mdimg.get_image_url(), 'not match on right-end-paren')
  end)
end)
