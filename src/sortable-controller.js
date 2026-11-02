// Rendered lists may be replaced repeatedly. Dispose each drag controller once.
export function createSortableController(create) {
  let current = null;
  function clear() {
    const previous = current;
    current = null;
    previous?.destroy();
  }
  return {
    clear,
    mount(element, options) {
      clear();
      if (element) current = create(element, options);
    },
    setDisabled(disabled) { current?.option('disabled', disabled); },
  };
}
