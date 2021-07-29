#ifndef BUILTIN_H_INCLUDED
#define BUILTIN_H_INCLUDED

// invoke

struct rb_builtin_function {
    // for invocation
    const void * const func_ptr;
    const int argc;

    // for load
    const int index;
    const char * const name;

    // for jit
    void (*compiler)(FILE *, long, unsigned, bool);
};

#define RB_BUILTIN_FUNCTION(_i, _name, _fname, _arity, _compiler) {\
  .name = #_name, \
  .func_ptr = (void *)_fname, \
  .argc = _arity, \
  .index = _i, \
  .compiler = _compiler, \
}

void rb_load_with_builtin_functions(const char *feature_name, const struct rb_builtin_function *table);

#ifndef rb_execution_context_t
typedef struct rb_execution_context_struct rb_execution_context_t;
#define rb_execution_context_t rb_execution_context_t
#endif

/* The following code is generated by the following Ruby script:

16.times{|i|
  args = (i > 0 ? ', ' : '') + (0...i).map{"VALUE"}.join(', ')
  puts "static inline void rb_builtin_function_check_arity#{i}(VALUE (*f)(rb_execution_context_t *ec, VALUE self#{args})){}"
}
*/

static inline void rb_builtin_function_check_arity0(VALUE (*f)(rb_execution_context_t *ec, VALUE self)){}
static inline void rb_builtin_function_check_arity1(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE)){}
static inline void rb_builtin_function_check_arity2(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity3(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity4(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity5(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity6(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity7(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity8(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity9(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity10(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity11(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity12(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity13(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity14(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}
static inline void rb_builtin_function_check_arity15(VALUE (*f)(rb_execution_context_t *ec, VALUE self, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE)){}

VALUE rb_vm_lvar_exposed(rb_execution_context_t *ec, int index);

// __builtin_inline!

PUREFUNC(static inline VALUE rb_vm_lvar(rb_execution_context_t *ec, int index));

static inline VALUE
rb_vm_lvar(rb_execution_context_t *ec, int index)
{
#if defined(VM_CORE_H_EC_DEFINED) && VM_CORE_H_EC_DEFINED
    return ec->cfp->ep[index];
#else
    return rb_vm_lvar_exposed(ec, index);
#endif
}

// dump/load

struct builtin_binary {
    const char *feature;          // feature name
    const unsigned char *bin;     // binary by ISeq#to_binary
    size_t bin_size;
};

#endif // BUILTIN_H_INCLUDED
