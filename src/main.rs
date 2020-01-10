//! Serval verification harness. 

#![feature(const_fn)]
#![no_std]

/*****************************/
/* Linked list-specific code */
/*****************************/

/*mod list;
use list::{List, ListLink, ListNode};

pub struct Link<'a> {
    next: ListLink<'a, Link<'a>>,
    //value: i32,
}

impl<'a> Link<'a> {
    pub const fn new() -> Self {
        Link {
            next: ListLink::empty(),
            //value: val,
        }
    }
}

impl<'a> ListNode<'a, Link<'a>> for Link<'a> {
    fn next(&'a self) -> &'a ListLink<'a, Link<'a>> {
        &self.next
    }
}

#[no_mangle]
static mut LINKLIST: LinkList = LinkList {
    len: 3,
};

struct LinkList {
    len: u64,
}

#[inline(never)]
#[no_mangle]
fn push_head() -> u64 {

    let new_size = unsafe { LINKLIST.len + 1 };
    unsafe { LINKLIST.len = new_size };
    new_size

}*/

/**************************/
/* TakeCell-specific code */
/**************************/

/*mod take_cell;
use take_cell::{TakeCell};

static mut TAKECELL: TakeCell<'static, [u8]> = TakeCell::empty();

#[inline(never)]
#[no_mangle]
fn take() -> Option<&'static mut [u8]> {

    unsafe { TAKECELL.take() }

}*/

/*********************************/
/* Static ref-specific code */
/*********************************/

mod static_ref;
use static_ref::{StaticRef};
use core::ops::Deref;

#[no_mangle]
pub static NPTINSTANCE: u64 = 0; 

#[no_mangle]
pub static mut STATICREF: StaticRef<u64> = unsafe { StaticRef::new(&NPTINSTANCE) };

#[inline(never)]
#[no_mangle]
fn deref() -> u64 {

    unsafe { *STATICREF.deref() }

}

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
