(function () {
  function initNavigation() {
    const nav = document.querySelector('.segi-nav');
    if (!nav) {
      return;
    }

    const toggle = nav.querySelector('.nav-toggle');
    const menuId = toggle ? toggle.getAttribute('aria-controls') : null;
    const menu = menuId ? document.getElementById(menuId) : nav.querySelector('.nav-center');
    const navLinks = nav.querySelectorAll('.nav-links a');
    const focusableSelectors = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled])';

    const closeMenu = () => {
      if (!nav.classList.contains('is-menu-open')) {
        return;
      }
      nav.classList.remove('is-menu-open');
      document.body.classList.remove('nav-menu-open');
      if (toggle) {
        toggle.setAttribute('aria-expanded', 'false');
        toggle.focus({ preventScroll: true });
      }
    };

    const openMenu = () => {
      if (!toggle || !menu) {
        return;
      }
      nav.classList.add('is-menu-open');
      document.body.classList.add('nav-menu-open');
      toggle.setAttribute('aria-expanded', 'true');
      const focusTarget = menu.querySelector(focusableSelectors);
      if (focusTarget) {
        focusTarget.focus({ preventScroll: true });
      }
    };

    if (toggle && menu) {
      toggle.setAttribute('aria-expanded', 'false');
      toggle.addEventListener('click', () => {
        if (nav.classList.contains('is-menu-open')) {
          closeMenu();
        } else {
          openMenu();
        }
      });
    }

    nav.addEventListener('keydown', event => {
      if (event.key === 'Escape') {
        closeMenu();
      }
    });

    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        closeMenu();
      });
    });

    document.addEventListener('click', event => {
      if (!nav.classList.contains('is-menu-open')) {
        return;
      }
      if (!nav.contains(event.target)) {
        closeMenu();
      }
    });

    const widthQuery = window.matchMedia('(min-width: 881px)');
    if (widthQuery.addEventListener) {
      widthQuery.addEventListener('change', evt => {
        if (evt.matches) {
          closeMenu();
        }
      });
    } else if (widthQuery.addListener) {
      widthQuery.addListener(evt => {
        if (evt.matches) {
          closeMenu();
        }
      });
    }
  }

  function registerSearchShortcut() {
    document.addEventListener('keydown', event => {
      if ((event.ctrlKey || event.metaKey) && event.key === '/') {
        const searchInput = document.querySelector('.segi-search-input');
        if (searchInput) {
          event.preventDefault();
          searchInput.focus();
          const value = searchInput.value;
          searchInput.value = '';
          searchInput.value = value;
        }
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      initNavigation();
      registerSearchShortcut();
    });
  } else {
    initNavigation();
    registerSearchShortcut();
  }
})();
