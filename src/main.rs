//! Linked list test/verification harness. 

extern crate list_lib;
use list_lib::{List, ListLink, ListNode};

pub struct Link<'a> {
    next: ListLink<'a, Link<'a>>,
}

impl<'a> Link<'a> {
    pub fn new() -> Self {
        Link {
            next: ListLink::empty(),
        }
    }
}

impl<'a> ListNode<'a, Link<'a>> for Link<'a> {
    fn next(&'a self) -> &'a ListLink<'a, Link<'a>> {
        &self.next
    }
}

/**
 * When using the linked list implementation, we run into the problem of a 
 * possible dangling pointer when `push_head()` takes in a `link` reference
 * if `link`'s lifetime is less than that of `list`. 
 *
 * Even if we do not use this dangling pointer, we must appease the compiler 
 * by ensuring that `link` lives at least as long as `list`. The following 
 * four blocks explore four different ways of doing this. 
 *
 * While we have only presented four methods, it is very likely that more exist. 
 **/

fn main() {

    // Never deallocates `link`'s memory so that any "dangling" pointer will 
    // still point to a valid memory region. 

    /*{
        let link = Box::leak(Box::new(Link::new()));
        let list = List::<'static, Link<'static>>::new();
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(link);
        println!("Head of one: {}", list.head().is_some());
    }*/

    // Allocates both list and link such that their lifetimes are the same. 

    {
        let list = List::new();
        let link = Link::new();
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(&link);
        println!("Head of one: {}", list.head().is_some());
    }

    // Allocates both list and link such that their lifetimes are the same. 
    // This syntax would be useful if allocating `list` and `link` on two 
    // different lines (as done above) resulted in two different lifetimes. 
    // This no longer seems to be the case in Rust, however, so this more 
    // convoluted syntax is no longer necessary. 

    /*{
        let (link, list) = (
            Link::new(),
            List::new()
        );
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(&link);
        println!("Head of one: {}", list.head().is_some());
    }*/

    // Forces both `link` and `list` into 'static lifetimes, and accesses 
    // the `link` reference through an unsafe block. The `new()` method in 
    // `ListLink` would also have to be `const`, which is undesireable for 
    // more complicated functionality. - why? TODO

    /*{
        static mut link: Link<'static> = Link::new();
        let list = List::<'static, Link<'static>>::new();
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(unsafe { &link });
        println!("Head of one: {}", list.head().is_some());
    }*/

}
