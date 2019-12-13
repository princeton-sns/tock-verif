//! Linked list verification harness. 

#![feature(const_fn)]
#![no_std]

mod list;
use list::{List, ListLink, ListNode};

pub struct Link<'a> {
    next: ListLink<'a, Link<'a>>,
}

impl<'a> Link<'a> {
    pub const fn new() -> Self {
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

/*
 * Functions to verify. 
 */

#[inline(never)]
#[no_mangle]
fn init() -> u32 {

    let list = List::<'_, Link<'_>>::new();
    list.iter().count() as u32

}
/*
#[inline(never)]
#[no_mangle]
fn init_head() -> u32 {

    let list = List::new();
    let link = Link::new();
    list.push_head(&link);
    list.iter().count() as u32

}

#[inline(never)]
#[no_mangle]
fn init_tail() -> usize {

    let list = List::new();
    let link = Link::new();
    list.push_tail(&link);
    list.iter().count()

}
*/
/*
 * When using the linked list implementation, we run into the problem of a 
 * possible dangling pointer when `push_head()` takes in a `link` reference
 * if `link`'s lifetime is less than that of `list`. 
 *
 * Even if we do not use this dangling pointer, we must appease the compiler 
 * by ensuring that `link` lives at least as long as `list`. The following 
 * four blocks explore four different ways of doing this. 
 *
 * While we have only presented four methods, it is very likely that more exist. 
 */

//fn main() {

    // Never deallocates `link`'s memory so that any "dangling" pointer will 
    // still point to a valid memory region. 

    /*{
        let link = Box::leak(Box::new(Link::new()));
        let list = List::<'static, Link<'static>>::new();
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(link);
        println!("Head of one: {}", list.head().is_some());
    }*/

    // Allocates both `list` and `link` such that their lifetimes are the same. 

    /*{
        let list = List::new();
        let link1 = Link::new();
        let link2 = Link::new();
        let link3 = Link::new();

        println!("Head of empty: {}", list.head().is_some());

        list.push_head(&link1);

        println!("Head of one: {}", list.head().is_some());

        list.push_head(&link2);
        list.push_head(&link3);

        let iter = list.iter();

        // Expect: 3
        println!("Size: {}", iter.count());
    }*/

    // Allocates both `list` and `link` such that their lifetimes are the same. 
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
    // more complicated functionality.

    /*{
        static mut LINK: Link<'static> = Link::new();
        let list = List::<'static, Link<'static>>::new();
        println!("Head of empty: {}", list.head().is_some());
        list.push_head(unsafe { &LINK });
        println!("Head of one: {}", list.head().is_some());
    }*/

//}
