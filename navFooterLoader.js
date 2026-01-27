document.addEventListener('DOMContentLoaded', () => {
  const normalizePath = (raw) => {
    if (!raw) return '';
    try {
      // If full URL provided, extract pathname
      if (/^https?:\/\//.test(raw)) raw = new URL(raw).pathname;
    } catch (e) {
      // ignore URL parsing errors and use raw value
    }
    // Remove leading/trailing slashes
    raw = raw.replace(/^\//, '').replace(/\/$/, '');
    // Remove .html extension for matching
    raw = raw.replace(/\.html$/, '');
    return raw;
  };

  const setActiveNav = () => {
    const navLinks = document.querySelectorAll('.segi-nav .nav-link');
    if (!navLinks.length) return;

    // Normalize current path: '' -> index
    let current = normalizePath(window.location.pathname);
    if (!current) current = 'index';

    navLinks.forEach(a => {
      const hrefRaw = a.getAttribute('href') || '';
      let href = normalizePath(hrefRaw);
      if (!href) href = 'index';

      // Match either exact page or prefix (handles pretty URLs like /teachers/)
      const isMatch = (current === href) || (current.startsWith(href + '/')) || (href !== 'index' && current.startsWith(href));

      if (isMatch) {
        a.classList.add('active');
      } else {
        a.classList.remove('active');
      }
    });
  };

  // Attach click handlers so active state updates immediately on click
  const attachClickHandlers = () => {
    const navLinks = document.querySelectorAll('.segi-nav .nav-link');
    if (!navLinks.length) return;

    // Replace nodes to remove old listeners (idempotent)
    navLinks.forEach(a => a.replaceWith(a.cloneNode(true)));

    // Re-query after clone
    const freshLinks = document.querySelectorAll('.segi-nav .nav-link');

    const setImmediateActive = (el) => {
      freshLinks.forEach(x => x.classList.remove('active'));
      el.classList.add('active');
    };

    freshLinks.forEach(a => {
      a.addEventListener('click', () => {
        setImmediateActive(a);
      });

      // Add keyboard handlers so Enter/Space provide immediate feedback
      a.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          setImmediateActive(a);
        }
      });
    });
  };

  // Run once in case nav is already present in the page (static nav)
  setActiveNav();

  // If page includes a container to load shared nav/footer, fetch and inject it,
  // then set the active link immediately after injection.
  const container = document.getElementById('nav-footer');
  if (container) {
    fetch('navFooter.html')
      .then(res => res.text())
      .then(html => {
        container.innerHTML = html;
        // Nav markup now in DOM — update active link
        setActiveNav();
        // And attach click handlers for immediate feedback
        attachClickHandlers();
      })
      .catch(err => {
        // Keep console message for debugging; don't throw.
        console.error('Failed to load navFooter.html:', err);
      });
  }
  // If nav is static on page, ensure click handlers are attached as well
  attachClickHandlers();
});
